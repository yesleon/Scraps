//
//  AttachmentList.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/7.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import Combine
import CoreGraphics


class AttachmentList {
    enum Message {
        case save(NewAttachment, with: Attachment.Identifier)
        case load(Attachment.Identifier, targetDimension: CGFloat)
        case delete(Attachment.Identifier)
    }
    static let shared = AttachmentList()
    @Published private(set) var value = [Attachment.Identifier: Attachment]()
    var subject = PassthroughSubject<Message, Never>()
    
    
    func modifyValue(handler: (inout [Attachment.Identifier: Attachment]) -> Void) {
        var value = self.value
        handler(&value)
        self.value = value
    }
}
