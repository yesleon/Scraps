//
//  ThoughtList.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

class ThoughtList {
    
    static let shared = ThoughtList()
    
    @Published private(set) var value = Set<Thought>()
    
    func modifyValue(handler: (inout Set<Thought>) -> Void) {
        var value = self.value
        handler(&value)
        self.value = value
    }
    
}
