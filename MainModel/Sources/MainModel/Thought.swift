//
//  Thought.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation


/// Basic data structure.
public struct Thought: Codable, Hashable {
    public init(content: String, date: Date) {
        self.content = content
        self.date = date
        self.tags = []
    }
    
    public var content: String
    public var date: Date
    public var tags: Set<Tag>?
}

public struct Tag: Codable, Hashable {
    public var title: String
    public init(_ title: String) {
        self.title = title
    }
}

public enum TagFilter: Equatable {
    case noTags, hasTags(Set<Tag>)
}
