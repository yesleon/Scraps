//
//  Thought.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

struct Thought: Codable, Hashable {
    struct Identifier: Codable, Hashable {
        let uuid = UUID()
    }
    var content: String
    var date: Date
    var tagIDs: Set<Tag.Identifier>
}
