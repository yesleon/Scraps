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
    var content: String
    var date: Date
    var tags: [Tag]?
}

struct Tag: Codable, Hashable {
    var title: String
}
