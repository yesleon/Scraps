//
//  ScrapList.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

class ScrapList: Model<[Scrap.Identifier: Scrap]> {
    
    static let shared = ScrapList(value: [Scrap.Identifier: Scrap]())
    
    func publisher(for id: Scrap.Identifier) -> AnyPublisher<Scrap, Never> {
        return $value
            .compactMap { $0[id] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}
