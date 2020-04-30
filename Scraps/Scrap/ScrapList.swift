//
//  ScrapList.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

class ScrapList: Model<IdentifiableSet<Scrap>> {
    
    static let shared = ScrapList(value: [])
    
    func publisher(for id: Scrap.ID) -> AnyPublisher<Scrap, Never> {
        return $value
            .compactMap { $0[id] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}
