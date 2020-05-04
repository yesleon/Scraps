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
    
    private var subscriptions = Set<AnyCancellable>()
    
    let scrapsSubject = Subject<IdentifiableSet<Scrap>>(.init())
    
    let tagsSubject = Subject<IdentifiableSet<Tag>>(.init())
    
    let scrapFiltersSubject = Subject<[ScrapFilter]>(.init())
    
    init() {
        tagsSubject
            .map(\.keys)
            .map(Set.init)
            .withOldValue(initialValue: Set<Tag.ID>())
            .map { $0.oldValue.subtracting($0.newValue) }
            .sink(receiveValue: { deletedTagIDs in
                self.scrapsSubject.value.modifyEach { scrap in
                    scrap.tagIDs.subtract(deletedTagIDs)
                }
                self.scrapFiltersSubject.value.modifyValue(ofType: ScrapFilters.TagFilter.self) { tagFilter in
                    if case let .hasTags(tags) = tagFilter {
                        tagFilter = .hasTags(tags.subtracting(deletedTagIDs))
                    }
                }
            })
            .store(in: &subscriptions)
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
        !value.contains(where: { $0.value.title == title }) && !title.isEmpty && !title.hasPrefix("#") && !title.contains(",")
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
