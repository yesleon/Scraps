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
    
    private let currentValueSubject = CurrentValueSubject<[Attachment.Identifier: Attachment], Never>([Attachment.Identifier: Attachment]())
    
    private let loadingSubject = PassthroughSubject<(id: Attachment.Identifier, targetDimension: CGFloat), Never>()
    
    var value: [Attachment.Identifier: Attachment] {
        currentValueSubject.value
    }
    
    func loadingPublisher() -> AnyPublisher<(id: Attachment.Identifier, targetDimension: CGFloat), Never> {
        loadingSubject.eraseToAnyPublisher()
    }
    
    func modifyValue(handler: (inout [Attachment.Identifier: Attachment]) -> Void) {
        var value = self.value
        handler(&value)
        self.currentValueSubject.value = value
    }
    
    func publisher() -> AnyPublisher<[Attachment.Identifier: Attachment], Never> {
        currentValueSubject.eraseToAnyPublisher()
    }
    
    func publisher(for id: Attachment.Identifier, targetDimension: CGFloat) -> AnyPublisher<Attachment, Never> {
        loadingSubject.send((id: id, targetDimension: targetDimension))
        return publisher().compactMap { $0[id] }.eraseToAnyPublisher()
    }
}
