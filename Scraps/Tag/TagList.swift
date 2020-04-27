//
//  TagList.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import Combine

class TagList: Model<[Tag.Identifier: Tag]> {
    
    static let shared = TagList(value: [Tag.Identifier: Tag]())
    
    func isTitleValid(_ title: String) -> Bool {
        !value.contains(where: { $0.value.title == title }) && !title.isEmpty && !title.hasPrefix("#") && !title.contains(",")
    }
    
    func publisher(for id: Tag.Identifier) -> AnyPublisher<Tag, Never> {
        return $value
            .compactMap { $0[id] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}
