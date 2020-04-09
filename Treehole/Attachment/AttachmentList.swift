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
    static let shared = AttachmentList()
    
    private let currentValuePublisher = CurrentValueSubject<[Attachment.Identifier: Attachment], Never>([Attachment.Identifier: Attachment]())
    
    var value: [Attachment.Identifier: Attachment] {
        currentValuePublisher.value
    }
    
    let loadMessageSubject = PassthroughSubject<(id: Attachment.Identifier, targetDimension: CGFloat), Never>()
    
    
    func modifyValue(handler: (inout [Attachment.Identifier: Attachment]) -> Void) {
        var value = self.value
        handler(&value)
        self.currentValuePublisher.value = value
    }
    
    func publisher() -> AnyPublisher<[Attachment.Identifier: Attachment], Never> {
        currentValuePublisher.eraseToAnyPublisher()
    }
    
    func publisher(for id: Attachment.Identifier, targetDimension: CGFloat) -> AnyPublisher<Attachment, Never> {
        loadMessageSubject.send((id: id, targetDimension: targetDimension))
        return publisher().compactMap { $0[id] }.eraseToAnyPublisher()
    }
}
