//
//  AttachmentList.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/7.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import Combine
import CoreGraphics


class AttachmentList {
    static let shared = AttachmentList()
    
    private let loadingSubject = PassthroughSubject<(id: Attachment.Identifier, targetDimension: CGFloat), Never>()
    
    @Published private(set) var value = [Attachment.Identifier: Attachment]()
    
    func loadingPublisher() -> AnyPublisher<(id: Attachment.Identifier, targetDimension: CGFloat), Never> {
        loadingSubject.eraseToAnyPublisher()
    }
    
    func modifyValue(handler: (inout [Attachment.Identifier: Attachment]) -> Void) {
        var value = self.value
        handler(&value)
        self.value = value
    }
    
    func publisher(for id: Attachment.Identifier, targetDimension: CGFloat) -> AnyPublisher<Attachment?, Never> {
        loadingSubject.send((id: id, targetDimension: targetDimension))
        return $value.map { $0[id] }.eraseToAnyPublisher()
    }
}
