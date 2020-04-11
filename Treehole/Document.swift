//
//  Document.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

import LinkPresentation
import AVFoundation

private struct DocumentData: Codable {
    var thoughts: [Thought.Identifier: Thought]
    var tags: [Tag.Identifier: Tag]
    var linkIDs: Set<Attachment.Identifier>?
    var imageIDs: Set<Attachment.Identifier>?
}

extension CGFloat {
    static let maxDimension: CGFloat = 1024
    static let itemWidth: CGFloat = 200
}

/// The Model. Holds data and publishes data changes. I/O to disk.
/// Converts between disk data structure and data structure in app.
class Document: UIDocument {
    
    enum Error: Swift.Error {
        case readingError(Any)
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    var assetFolders = [String: FileWrapper]()
    
    func subscribe() {
        
        AttachmentList.shared.$value
            .map({ attachments in
                var newAssetFolders = [String: FileWrapper]()
                attachments.forEach { id, attachment in
                    guard case let .image(images) = attachment else { return }
                    let imageID = id.url.lastPathComponent
                    var imageFiles = self.assetFolders[imageID]?.fileWrappers ?? [:]
                    images.forEach { dimension, image in
                        if imageFiles["\(dimension)"] == nil, let data = image.jpegData(compressionQuality: 0.95) {
                            imageFiles["\(dimension)"] = FileWrapper(regularFileWithContents: data)
                        }
                    }
                    
                    newAssetFolders[imageID] = FileWrapper(directoryWithFileWrappers: imageFiles)
                }
                return newAssetFolders
            })
            .assign(to: \.assetFolders, on: self)
            .store(in: &subscriptions)
        
        AttachmentList.shared.loadingPublisher()
            .combineLatest(AttachmentList.shared.$value)
            .compactMap({ (loadingMessage, attachments) -> (Attachment.Identifier, Attachment, CGFloat)? in
                guard let attachment = attachments[loadingMessage.id] else { return nil }
                return (loadingMessage.id, attachment, loadingMessage.targetDimension)
            })
            .sink(receiveValue: { id, attachment, targetDimension in
                switch attachment {
                case var .image(images):
                    guard images[targetDimension] == nil else { break }
                    guard let data = self.assetFolders[id.url.lastPathComponent]?.fileWrappers?["\(CGFloat.maxDimension)"]?.regularFileContents else { break }
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
                    
                }
            })
            .store(in: &subscriptions)
        
        weak var undoManager = self.undoManager
        
        AttachmentList.shared.$value
            .previousResult(initialResult: [Attachment.Identifier : Attachment]())
            .sink(receiveValue: { oldValue in
                undoManager?.registerUndo(withTarget: AttachmentList.shared) {
                    $0.modifyValue {
                        $0 = oldValue
                    }
                }
            })
            .store(in: &subscriptions)
        
        
        ThoughtList.shared.$value
            .previousResult(initialResult: [Thought.Identifier : Thought]())
            .sink(receiveValue: { oldValue in
                undoManager?.registerUndo(withTarget: ThoughtList.shared) {
                    $0.modifyValue {
                        $0 = oldValue
                    }
                }
            })
            .store(in: &subscriptions)
        
        TagList.shared.$value
            .previousResult(initialResult: [Tag.Identifier : Tag]())
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
        assetFolders = rootFolder.fileWrappers?["assets"]?.fileWrappers ?? [:]
        if let data = rootFolder.fileWrappers?["data.json"]?.regularFileContents {
            let documentData = try JSONDecoder().decode(DocumentData.self, from: data)
            TagList.shared.modifyValue { tags in
                tags = documentData.tags
            }
            ThoughtList.shared.modifyValue { thoughts in
                thoughts = documentData.thoughts
            }
            AttachmentList.shared.modifyValue { attachments in
                documentData.imageIDs?.forEach {
                    if attachments[$0] == nil {
                        attachments[$0] = .image([:])
                    }
                }
                documentData.linkIDs?.forEach {
                    if attachments[$0] == nil {
                        attachments[$0] = .linkMetadata(.init(originalURL: $0.url))
                    }
                }
            }
        }
        
        undoManager.removeAllActions()
    }
    
    override func contents(forType typeName: String) throws -> Any {
        var links = Set<Attachment.Identifier>()
        var imageIDs = Set<Attachment.Identifier>()
        AttachmentList.shared.value.forEach { id, attachment in
            switch attachment {
            case .image(_):
                imageIDs.insert(id)
            case .linkMetadata(_):
                links.insert(id)
            }
        }
        let data = try JSONEncoder().encode(DocumentData(thoughts: ThoughtList.shared.value, tags: TagList.shared.value, linkIDs: links, imageIDs: imageIDs))
        return FileWrapper(directoryWithFileWrappers: [
            "data.json": FileWrapper(regularFileWithContents: data),
            "assets": FileWrapper(directoryWithFileWrappers: assetFolders)
        ])
    }
    
    override func handleError(_ error: Swift.Error, userInteractionPermitted: Bool) {
        super.handleError(error, userInteractionPermitted: userInteractionPermitted)
        print(error)
    }
}


