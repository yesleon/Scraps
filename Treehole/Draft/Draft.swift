//
//  Draft.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class Draft {
    static let shared = Draft()
    
    @Published var value = ""
    @Published var attachment: NewAttachment?
    
    func publish() {
        var tagIDs = Set<Tag.Identifier>()
        if case let .hasTags(selectedTagIDs) = ThoughtFilter.shared.value.first(ofType: TagFilter.self) {
            tagIDs = selectedTagIDs
        }
        let attachmentID = attachment.map(Attachment.Identifier.init(newAttachment:))
        
        ThoughtList.shared.modifyValue {
            $0[.init()] = .init(content: value, date: .init(), tagIDs: tagIDs, attachmentID: attachmentID)
        }
        
        if let attachment = attachment, let id = attachmentID {
            AttachmentList.shared.subject.send(.save(attachment, with: id))
        }
        
        value.removeAll()
        attachment = nil
    }
}

enum NewAttachment {
    case image(UIImage), link(URL)
}
