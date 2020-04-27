//
//  Model.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/28.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation


class Model<Value> {
    
    init(value: Value) {
        self.value = value
    }
    
    @Published private(set) var value: Value
    
    func modifyValue(handler: (inout Value) throws -> Void) rethrows {
        var value = self.value
        try handler(&value)
        self.value = value
    }
    
}
