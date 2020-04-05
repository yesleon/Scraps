//
//  Thought.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

/// Basic data structure.
struct Thought: Codable, Hashable {
    struct Identifier: Codable, Hashable {
        let uuid: UUID
        init() {
            uuid = .init()
        }
    }
    var content: String
    var date: Date
    var tagIDs: Set<Tag.Identifier>
}

struct Tag: Codable, Hashable {
    struct Identifier: Codable, Hashable {
        let uuid: UUID
        init() {
            uuid = .init()
        }
    }
    var title: String
}

enum TagFilter: Equatable {
    case noTags, hasTags(Set<Tag.Identifier>)
}
