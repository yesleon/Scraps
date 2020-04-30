//
//  Tag.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation


struct Tag: Codable, Equatable, FileWrapperConvertible, Identifiable {
    var id: UUID
    var title: String
}

struct Tag0_5: Codable, Equatable, FileWrapperConvertible {
    typealias Identifier = UUIDIdentifier
    var title: String
}



extension IdentifiableSet where Element == Tag {
    
    init(tagDict: [Tag0_5.Identifier: Tag0_5]) {
        self.init()
        tagDict.forEach {
            self.insert(.init(id: $0.key.uuid, title: $0.value.title))
        }
    }
    
}
