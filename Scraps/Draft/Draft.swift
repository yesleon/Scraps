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
        attachment = .init(kind: .drawing, content: drawing.dataRepresentation())
    }
    
    func saveImage(_ image: UIImage) {
        attachment = .init(kind: .image, content: image.jpegData(compressionQuality: 0.95)!)
    }
    
    func saveURL(_ url: URL) {
        let metadata = LPLinkMetadata()
        metadata.originalURL = url
        let data = try! NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: false)
        attachment = .init(kind: .linkMetadata, content: data)
        LPMetadataProvider().startFetchingMetadata(for: url) { metadata, error in
            if let metadata = metadata {
                DispatchQueue.main.async { [weak self] in
                    let data = try! NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: false)
                    self?.attachment = .init(kind: .linkMetadata, content: data)
                }
            }
        }
    }
    
    func deleteAttachment() {
        attachment = nil
    }
    
    func publish() {
        
        var tagIDs = Set<Tag.ID>()
        if case let .hasTags(selectedTagIDs) = Model.shared.scrapFiltersSubject.value.first(ofType: ScrapFilters.TagFilter.self) {
            tagIDs = selectedTagIDs
        }
        
        Model.shared.scrapsSubject.value.insert(.init(id: .init(), content: value, date: .init(), tagIDs: tagIDs, attachment: attachment))
        
        value.removeAll()
        attachment = nil
    }
}
