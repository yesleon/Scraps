//
//  ThoughtList.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import Combine

class ThoughtList {
    
    static let shared = ThoughtList()
    
    private let currentValueSubject = CurrentValueSubject<[Thought.Identifier: Thought], Never>([Thought.Identifier: Thought]())
    
    var value: [Thought.Identifier: Thought] {
        currentValueSubject.value
    }
    
    func modifyValue(handler: (inout [Thought.Identifier: Thought]) -> Void) {
        var value = currentValueSubject.value
        handler(&value)
        currentValueSubject.value = value
    }
    
    func publisher() -> AnyPublisher<[Thought.Identifier: Thought], Never> {
        currentValueSubject.eraseToAnyPublisher()
    }
    
    func publisher(for id: Thought.Identifier) -> AnyPublisher<Thought, Never> {
        return currentValueSubject
            .compactMap { $0[id] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}
