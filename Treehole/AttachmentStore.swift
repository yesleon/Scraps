//
//  AttachmentStore.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/7.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import Combine
import UIKit
import LinkPresentation
import func AVFoundation.AVMakeRect

extension URL {
    
    fileprivate static let assetsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("assets")
    
    fileprivate static func imageURL(id: Attachment.Identifier, targetDimension: CGFloat) -> URL {
        assetsURL.appendingPathComponent(String(id.url.path.dropFirst())).appendingPathComponent(String(Int(targetDimension)))
    }
}


extension CGFloat {
    static let maxDimension: CGFloat = 1080
}

class AttachmentStore {
    var subscriptions = Set<AnyCancellable>()
    
    func load() {
        AttachmentList.shared.modifyValue { attachments in
            do {
                try FileManager.default.contentsOfDirectory(at: .assetsURL, includingPropertiesForKeys: nil, options: [])
                    .compactMap({ url -> URL? in
                        var components = URLComponents()
                        components.scheme = "treehole"
                        components.host = "assets"
                        components.path = "/" + url.deletingPathExtension().lastPathComponent
                        return components.url
                    })
                    .map(Attachment.Identifier.init(url:))
                    .forEach({ imageID in
                        attachments[imageID] = .init(loadedContent: .image([:]))
                    })
                
            } catch {
                print(error)
            }
        }
        
        AttachmentList.shared.subject
            .sink(receiveValue: {
                switch $0 {
                case let .save(attachment, with: id):
                    AttachmentList.shared.modifyValue { attachments in
                        switch attachment {
                            
                        case let .image(image) :
                            do {
                                let rect = AVMakeRect(aspectRatio: image.size, insideRect: .init(x: 0, y: 0, width: .maxDimension, height: .maxDimension))
                                let format = UIGraphicsImageRendererFormat.default()
                                format.scale = 1
                                let data = UIGraphicsImageRenderer(bounds: rect, format: format).jpegData(withCompressionQuality: 0.95) { context in
                                    image.draw(in: rect)
                                }
                                let url = URL.imageURL(id: id, targetDimension: .maxDimension)
                                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                                try data.write(to: url)
                            } catch {
                                print(error)
                            }
                            attachments[id] = .init(loadedContent: .image([:]))
                        case .link(_):
                            attachments[id] = .init(loadedContent: .linkMetadata(nil))
                        }
                    }
                case let .load(id, targetDimension: targetDimension):
                    
                    if var attachment = AttachmentList.shared.value[id] {
                        switch attachment.loadedContent {
                        case var .image(image):
                            if image[targetDimension] == nil {
                                do {
                                    let data = try Data(contentsOf: .imageURL(id: id, targetDimension: .maxDimension))
                                    let originalImage = UIImage(data: data)!
                                    let width = targetDimension
                                    
                                    
                                    let rect = AVMakeRect(aspectRatio: originalImage.size, insideRect: .init(x: 0, y: 0, width: width, height: width))
                                    let targetImage = UIGraphicsImageRenderer(bounds: rect).image { context in
                                        originalImage.draw(in: rect)
                                    }
                                    try targetImage.jpegData(compressionQuality: 0.95)?.write(to: .imageURL(id: id, targetDimension: width))
                                    
                                    image[targetDimension] = targetImage
                                    attachment.loadedContent = .image(image)
                                    
                                    AttachmentList.shared.modifyValue { attachments in
                                        attachments[id] = attachment
                                    }
                                    
                                } catch {
                                    print(error)
                                }
                            }
                        case .linkMetadata(let metadata):
                            if metadata == nil {
                                LPMetadataProvider().startFetchingMetadata(for: id.url) { metadata, error in
                                    if let metadata = metadata {
                                        DispatchQueue.main.async {
                                            AttachmentList.shared.modifyValue {
                                                $0[id] = .init(loadedContent: .linkMetadata(metadata))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        LPMetadataProvider().startFetchingMetadata(for: id.url) { metadata, error in
                            if let metadata = metadata {
                                DispatchQueue.main.async {
                                    AttachmentList.shared.modifyValue {
                                        $0[id] = .init(loadedContent: .linkMetadata(metadata))
                                    }
                                }
                            }
                        }
                    }
                case .delete(let id):
                    do {
                        try FileManager.default.removeItem(at: URL.assetsURL.appendingPathComponent(String(id.url.path.dropFirst())))
                    } catch {
                        print(error)
                    }
                }
            })
            .store(in: &subscriptions)
    }
    
}
