//
//  Model.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/28.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import Combine
import CoreGraphics

typealias Subject<Value> = CurrentValueSubject<Value, Never>

class Model {
    
    static let shared = Model()
    
    let scrapsSubject = Subject<IdentifiableSet<Scrap>>(.init())
    
    let tagsSubject = Subject<IdentifiableSet<Tag>>(.init())
    
    let scrapFiltersSubject = Subject<[ScrapFilter]>(.init())
    
    let attachmentsSubject = Subject<[Attachment.Identifier: Attachment]>(.init())
    
    let loadingSubject = PassthroughSubject<(id: Attachment.Identifier, targetDimension: CGFloat), Never>()
    
    func publisher(for id: Attachment.Identifier, targetDimension: CGFloat) -> AnyPublisher<Attachment?, Never> {
        loadingSubject.send((id: id, targetDimension: targetDimension))
        return attachmentsSubject.map { $0[id] }.eraseToAnyPublisher()
    }
    
}

extension CurrentValueSubject where Output == IdentifiableSet<Scrap>, Failure == Never {
    
    func publisher(for id: Scrap.ID) -> AnyPublisher<Scrap, Never> {
        return self
            .compactMap { $0[id] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}

extension CurrentValueSubject where Output == IdentifiableSet<Tag>, Failure == Never {
    
    func isTitleValid(_ title: String) -> Bool {
        !value.contains(where: { $0.title == title }) && !title.isEmpty && !title.hasPrefix("#") && !title.contains(",")
    }
    
    func publisher(for id: Tag.ID) -> AnyPublisher<Tag, Never> {
        return self
            .compactMap { $0[id] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}

extension Array where Element == ScrapFilter {
    
    mutating func modifyValue<T: ScrapFilter>(ofType type: T.Type, handler: (inout T?) -> Void) {
        let index = firstIndex(where: { $0 is T })
        if let index = index, let filter = self[index] as? T {
            var filter: T? = filter
            handler(&filter)
            if let filter = filter {
                self[index] = filter
            } else {
                remove(at: index)
            }
        } else {
            var filter: T?
            handler(&filter)
            if let filter = filter {
                append(filter)
            }
        }
    }
    
}
