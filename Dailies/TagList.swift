//
//  TagList.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

class TagList {
    
    static let shared = TagList()
    
    @Published private(set) var value = Set<Tag>() 
    
    func isTitleValid(_ title: String) -> Bool {
        !value.contains(where: { $0.title == title }) && !title.isEmpty && !title.hasPrefix("#") && !title.contains(",")
    }
    
    func modifyValue(handler: (inout Set<Tag>) -> Void) {
        var value = self.value
        handler(&value)
        self.value = value
    }
}
