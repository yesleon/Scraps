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
    
    @Published private(set) var value = [Tag.Identifier: Tag]()
    
    func isTitleValid(_ title: String) -> Bool {
        !value.contains(where: { $0.value.title == title }) && !title.isEmpty && !title.hasPrefix("#") && !title.contains(",")
    }
    
    func modifyValue(handler: (inout [Tag.Identifier: Tag]) -> Void) {
        var value = self.value
        handler(&value)
        self.value = value
    }
}
