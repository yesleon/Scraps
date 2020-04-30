//
//  TagList.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import Combine

//class TagList: Model<IdentifiableSet<Tag>> {
//    
//    static let shared = TagList([])
//    
//    func isTitleValid(_ title: String) -> Bool {
//        !value.contains(where: { $0.title == title }) && !title.isEmpty && !title.hasPrefix("#") && !title.contains(",")
//    }
//    
//    func publisher(for id: Tag.ID) -> AnyPublisher<Tag, Never> {
//        return valuePublisher
//            .compactMap { $0[id] }
//            .removeDuplicates()
//            .eraseToAnyPublisher()
//    }
//    
//}
