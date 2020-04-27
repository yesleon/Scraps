//
//  ScrapList.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

class ScrapList {
    
    static let shared = ScrapList()
    
    @Published private(set) var value = [Scrap.Identifier: Scrap]()
    
    func modifyValue(handler: (inout [Scrap.Identifier: Scrap]) throws -> Void) rethrows {
        var value = self.value
        try handler(&value)
        self.value = value
    }
    
    func publisher(for id: Scrap.Identifier) -> AnyPublisher<Scrap, Never> {
        return $value
            .compactMap { $0[id] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}
