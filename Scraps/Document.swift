//
//  Document.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

import LinkPresentation
import PencilKit
import AVFoundation


/// The Model. Holds data and publishes data changes. I/O to disk.
/// Converts between disk data structure and data structure in app.
class Document: UIDocument {
    
    enum Error: Swift.Error {
        case readingError(Any)
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    var imageFolders = [String: FileWrapper]()
    
    func subscribe() {
        
        Model.shared.attachmentsSubject
            .map({ attachments in
                var newAssetFolders = [String: FileWrapper]()
                attachments.forEach { id, attachment in
                    guard case let .image(images) = attachment else { return }
                    let imageID = id.url.lastPathComponent
                    var imageFiles = self.imageFolders[imageID]?.fileWrappers ?? [:]
                    images.forEach { dimension, image in
                        if imageFiles["\(dimension)"] == nil, let data = image.jpegData(compressionQuality: 0.95) {
                            imageFiles["\(dimension)"] = FileWrapper(regularFileWithContents: data)
                        }
                    }
                    
                    newAssetFolders[imageID] = FileWrapper(directoryWithFileWrappers: imageFiles)
                }
                return newAssetFolders
            })
            .assign(to: \.imageFolders, on: self)
            .store(in: &subscriptions)
        
        Model.shared.loadingSubject
            .combineLatest(Model.shared.attachmentsSubject)
            .compactMap({ (loadingMessage, attachments) -> (Attachment.Identifier, Attachment, CGFloat)? in
                guard let attachment = attachments[loadingMessage.id] else { return nil }
                return (loadingMessage.id, attachment, loadingMessage.targetDimension)
            })
            .sink(receiveValue: { id, attachment, targetDimension in
                switch attachment {
                case var .image(images):
                    guard images[targetDimension] == nil else { break }
                    guard let data = self.imageFolders[id.url.lastPathComponent]?.fileWrappers?["\(CGFloat.maxDimension)"]?.regularFileContents else { break }
                    guard let originalImage  = UIImage(data: data) else { break }
                    
                    let rect = AVMakeRect(aspectRatio: originalImage.size, insideRect: .init(x: 0, y: 0, width: targetDimension, height: targetDimension))
                    let targetImage = UIGraphicsImageRenderer(bounds: rect).image { context in
                        originalImage.draw(in: rect)
                    }
                    
                    images[targetDimension] = targetImage
                    Model.shared.attachmentsSubject.value[id] = .image(images)
                    
                    
                case .linkMetadata(let metadata):
                    guard metadata.title == nil else { break }
                    LPMetadataProvider().startFetchingMetadata(for: id.url) { metadata, error in
                        if let metadata = metadata {
                            DispatchQueue.main.async {
                                Model.shared.attachmentsSubject.value[id] = .linkMetadata(metadata)
                            }
                        }
                    }
                    
                case .drawing(_):
                    break
                }
            })
            .store(in: &subscriptions)
        
        weak var undoManager = self.undoManager
        
        Model.shared.attachmentsSubject
            .previousResult(initialResult: [Attachment.Identifier : Attachment]())
            .sink(receiveValue: { oldValue in
                undoManager?.registerUndo(withTarget: Model.shared.attachmentsSubject) {
                    $0.value = oldValue
                }
            })
            .store(in: &subscriptions)
        
        
        Model.shared.scrapsSubject
            .previousResult(initialResult: [])
            .sink(receiveValue: { oldValue in
                undoManager?.registerUndo(withTarget: Model.shared.scrapsSubject) {
                    $0.value = oldValue
                }
            })
            .store(in: &subscriptions)
        
        Model.shared.tagsSubject
            .previousResult(initialResult: [])
            .sink(receiveValue: { oldValue in
                undoManager?.registerUndo(withTarget: Model.shared.tagsSubject) {
                    $0.value = oldValue
                }
            })
            .store(in: &self.subscriptions)
    }
    
    func openOrCreateIfFileNotExists(completionHandler: ((Bool) -> Void)? = nil) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            open(completionHandler: completionHandler)
        } else {
            save(to: fileURL, for: .forCreating, completionHandler: completionHandler)
        }
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let rootFolder = contents as? FileWrapper else { throw Error.readingError(contents) }
        guard let folders = rootFolder.fileWrappers else { throw Error.readingError(contents) }
        guard let scrapsFile = folders["Scraps"] else { throw Error.readingError(contents) }
        guard let tagsFile = folders["Tags"] else { throw Error.readingError(contents) }
        guard let linkIDsFile = folders["LinkIDs"] else { throw Error.readingError(contents) }
        guard let imageIDsFile = folders["ImageIDs"] else { throw Error.readingError(contents) }
        guard let drawingsFolder = folders["Drawings"] else { throw Error.readingError(contents) }
        guard let imagesFolder = folders["Images"] else { throw Error.readingError(contents) }
        
        
        
        imageFolders = imagesFolder.fileWrappers ?? [:]
        
        do {
            Model.shared.scrapsSubject.value = try .init(scrapsFile)
        } catch {
            let scraps = try [Scrap0_5.Identifier: Scrap0_5](scrapsFile)
            Model.shared.scrapsSubject.value = .init(scrapDict: scraps)
        }
        
        do {
            Model.shared.tagsSubject.value = try .init(tagsFile)
        } catch {
            let tags = try [Tag0_5.Identifier: Tag0_5](tagsFile)
            Model.shared.tagsSubject.value = .init(tagDict: tags)
        }
        try Set<Attachment.Identifier>(linkIDsFile).forEach { linkID in
            if Model.shared.attachmentsSubject.value[linkID] == nil {
                Model.shared.attachmentsSubject.value[linkID] = .linkMetadata(.init(originalURL: linkID.url))
            }
        }
        try Set<Attachment.Identifier>(imageIDsFile).forEach { imageID in
            if Model.shared.attachmentsSubject.value[imageID] == nil {
                Model.shared.attachmentsSubject.value[imageID] = .image([:])
            }
        }
        try [Attachment.Identifier: PKDrawing](drawingsFolder).forEach { id, drawing in
            if Model.shared.attachmentsSubject.value[id] == nil {
                Model.shared.attachmentsSubject.value[id] = .drawing(drawing)
            }
        }
        
        
        undoManager.removeAllActions()
    }
    
    override func contents(forType typeName: String) throws -> Any {
        var linkIDs = Set<Attachment.Identifier>()
        var imageIDs = Set<Attachment.Identifier>()
        var drawings = [Attachment.Identifier: PKDrawing]()
        Model.shared.attachmentsSubject.value.forEach { id, attachment in
            switch attachment {
            case .image(_):
                imageIDs.insert(id)
            case .linkMetadata(_):
                linkIDs.insert(id)
            case .drawing(let drawing):
                drawings[id] = drawing
            }
        }
        do {
            return FileWrapper(directoryWithFileWrappers: [
                "Scraps": try Model.shared.scrapsSubject.value.fileWrapperRepresentation(),
                "Tags": try Model.shared.tagsSubject.value.fileWrapperRepresentation(),
                "LinkIDs": try linkIDs.fileWrapperRepresentation(),
                "ImageIDs": try imageIDs.fileWrapperRepresentation(),
                "Drawings": try drawings.fileWrapperRepresentation(),
                "Images": FileWrapper(directoryWithFileWrappers: imageFolders),
            ])
        } catch {
            print(error)
            throw error
        }
    }
    
    override func handleError(_ error: Swift.Error, userInteractionPermitted: Bool) {
        super.handleError(error, userInteractionPermitted: userInteractionPermitted)
        print(error)
    }
}


