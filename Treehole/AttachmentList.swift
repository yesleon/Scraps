//
//  AttachmentList.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/7.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import Combine


class AttachmentList {
    enum Message {
        case save(NewAttachment, with: Attachment.Identifier)
        case load(Attachment.Identifier)
    }
    static let shared = AttachmentList()
    var value = [Attachment.Identifier: Attachment]()
    var subject = PassthroughSubject<Message, Never>()
}
