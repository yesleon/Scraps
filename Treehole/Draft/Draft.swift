//
//  Draft.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import AVFoundation
import LinkPresentation

class Draft {
    static let shared = Draft()
    
    @Published var value = ""
    @Published private(set) var attachment: Attachment?
    
    func saveImage(_ image: UIImage) {
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: .init(x: 0, y: 0, width: .maxDimension, height: .maxDimension))
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let image = UIGraphicsImageRenderer(bounds: rect, format: format).image { context in
            image.draw(in: rect)
        }
        attachment = .image([.maxDimension: image])
    }
    
    func saveURL(_ url: URL) {
        let metadata = LPLinkMetadata()
        metadata.originalURL = url
        attachment = .linkMetadata(metadata)
        LPMetadataProvider().startFetchingMetadata(for: url) { metadata, error in
            if let metadata = metadata {
                DispatchQueue.main.async { [weak self] in
                    self?.attachment = .linkMetadata(metadata)
                    
                }
            }
        }
    }
    
    func deleteAttachment() {
        attachment = nil
    }
    
    func publish() {
        
        let attachmentID: Attachment.Identifier? = {
            switch attachment {
            case .image(_):
                var components = URLComponents()
                components.scheme = "treehole"
                components.host = "assets"
                components.path = "/" + UUID().uuidString
                return components.url.map(Attachment.Identifier.init(url:))
            case .linkMetadata(let metadata):
                return  metadata.originalURL.map(Attachment.Identifier.init(url:))
            case .none:
                return nil
            }
        }()
        
        var tagIDs = Set<Tag.Identifier>()
        if case let .hasTags(selectedTagIDs) = ThoughtFilter.shared.value.first(ofType: TagFilter.self) {
            tagIDs = selectedTagIDs
        }
        
        if let attachment = attachment, let id = attachmentID {
            AttachmentList.shared.modifyValue {
                $0[id] = attachment
            }
        }
        
        ThoughtList.shared.modifyValue {
            $0[.init()] = .init(content: value, date: .init(), tagIDs: tagIDs, attachmentID: attachmentID)
        }
        
        value.removeAll()
        attachment = nil
    }
}
