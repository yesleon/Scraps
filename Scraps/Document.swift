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
        
        AttachmentList.shared.valuePublisher
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
        
        AttachmentList.shared.loadingPublisher()
            .combineLatest(AttachmentList.shared.valuePublisher)
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
                    
                    AttachmentList.shared.modifyValue { attachments in
                        attachments[id] = .image(images)
                    }
                    
                    
                case .linkMetadata(let metadata):
                    guard metadata.title == nil else { break }
                    LPMetadataProvider().startFetchingMetadata(for: id.url) { metadata, error in
                        if let metadata = metadata {
                            DispatchQueue.main.async {
                                AttachmentList.shared.modifyValue {
                                    $0[id] = .linkMetadata(metadata)
                                }
                            }
                        }
                    }
                    
                case .drawing(_):
                    break
                }
            })
            .store(in: &subscriptions)
        
        weak var undoManager = self.undoManager
        
        AttachmentList.shared.valuePublisher
            .previousResult(initialResult: [Attachment.Identifier : Attachment]())
            .sink(receiveValue: { oldValue in
                undoManager?.registerUndo(withTarget: AttachmentList.shared) {
                    $0.modifyValue {
                        $0 = oldValue
                    }
                }
            })
            .store(in: &subscriptions)
        
        
        ScrapList.shared.valuePublisher
            .previousResult(initialResult: [])
            .sink(receiveValue: { oldValue in
                undoManager?.registerUndo(withTarget: ScrapList.shared) {
                    $0.modifyValue {
                        $0 = oldValue
                    }
                }
            })
            .store(in: &subscriptions)
        
        TagList.shared.valuePublisher
            .previousResult(initialResult: [])
            .sink(receiveValue: { oldValue in
                undoManager?.registerUndo(withTarget: TagList.shared) {
                    $0.modifyValue {
                        $0 = oldValue
                    }
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
        try ScrapList.shared.modifyValue {
            do {
                $0 = try .init(scrapsFile)
            } catch {
                let scraps = try [Scrap0_5.Identifier: Scrap0_5](scrapsFile)
                $0 = .init(scrapDict: scraps)
            }
        }
        try TagList.shared.modifyValue {
            do {
                $0 = try .init(tagsFile)
            } catch {
                let tags = try [Tag0_5.Identifier: Tag0_5](tagsFile)
                $0 = .init(tagDict: tags)
            }
        }
        try AttachmentList.shared.modifyValue { attachments in
            try Set<Attachment.Identifier>(linkIDsFile).forEach { linkID in
                if attachments[linkID] == nil {
                    attachments[linkID] = .linkMetadata(.init(originalURL: linkID.url))
                }
            }
            try Set<Attachment.Identifier>(imageIDsFile).forEach { imageID in
                if attachments[imageID] == nil {
                    attachments[imageID] = .image([:])
                }
            }
            try [Attachment.Identifier: PKDrawing](drawingsFolder).forEach { id, drawing in
                if attachments[id] == nil {
                    attachments[id] = .drawing(drawing)
                }
            }
        }
        
        undoManager.removeAllActions()
    }
    
    override func contents(forType typeName: String) throws -> Any {
        var linkIDs = Set<Attachment.Identifier>()
        var imageIDs = Set<Attachment.Identifier>()
        var drawings = [Attachment.Identifier: PKDrawing]()
        AttachmentList.shared.value.forEach { id, attachment in
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
                "Scraps": try ScrapList.shared.value.fileWrapperRepresentation(),
                "Tags": try TagList.shared.value.fileWrapperRepresentation(),
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


