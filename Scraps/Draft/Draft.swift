//
//  Draft.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import AVFoundation
import PencilKit
import LinkPresentation

class Draft {
    static let shared = Draft()
    
    @Published var value = ""
    @Published private(set) var attachment: Attachment?
    
    func saveDrawing(_ drawing: PKDrawing) {
        attachment = .drawing(drawing)
    }
    
    func saveImage(_ image: UIImage, dimensions: [CGFloat]) {
        var images = [CGFloat: UIImage]()
        dimensions.forEach {
            let rect = AVMakeRect(aspectRatio: image.size, insideRect: .init(x: 0, y: 0, width: $0, height: $0))
            let format = UIGraphicsImageRendererFormat.default()
            format.scale = UIScreen.main.scale
            images[$0] = UIGraphicsImageRenderer(bounds: rect, format: format).image { context in
                image.draw(in: rect)
            }
        }
        attachment = .image(images)
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
            case .drawing(_):
                var components = URLComponents()
                components.scheme = "treehole"
                components.host = "attachments"
                components.path = "/" + UUID().uuidString
                return components.url.map(Attachment.Identifier.init(url:))
            }
        }()
        
        var tagIDs = Set<Tag.ID>()
        if case let .hasTags(selectedTagIDs) = ScrapFilterList.shared.value.first(ofType: ScrapFilters.TagFilter.self) {
            tagIDs = selectedTagIDs
        }
        
        if let attachment = attachment, let id = attachmentID {
            AttachmentList.shared.modifyValue {
                $0[id] = attachment
            }
        }
        
        ScrapList.shared.modifyValue {
            $0.insert(.init(id: .init(), content: value, date: .init(), tagIDs: tagIDs, attachmentID: attachmentID))
        }
        
        value.removeAll()
        attachment = nil
    }
}
