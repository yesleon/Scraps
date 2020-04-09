//
//  ThoughtList.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import Combine

typealias AnyCancellable = Combine.AnyCancellable

class ThoughtList {
    
    static let shared = ThoughtList()
    
    @Published private(set) var value = [Thought.Identifier: Thought]()
    
    func modifyValue(handler: (inout [Thought.Identifier: Thought]) -> Void) {
        var value = self.value
        handler(&value)
        self.value = value
    }
    
    func publisher(for id: Thought.Identifier) -> AnyPublisher<Thought, Never> {
        return $value
            .compactMap { $0[id] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}
