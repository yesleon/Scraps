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


class AttachmentList: Model<[Attachment.Identifier: Attachment]> {
    static let shared = AttachmentList(value: [Attachment.Identifier: Attachment]())
    
    private let loadingSubject = PassthroughSubject<(id: Attachment.Identifier, targetDimension: CGFloat), Never>()
    
    func loadingPublisher() -> AnyPublisher<(id: Attachment.Identifier, targetDimension: CGFloat), Never> {
        loadingSubject.eraseToAnyPublisher()
    }
    
    func publisher(for id: Attachment.Identifier, targetDimension: CGFloat) -> AnyPublisher<Attachment?, Never> {
        loadingSubject.send((id: id, targetDimension: targetDimension))
        return $value.map { $0[id] }.eraseToAnyPublisher()
    }
}
