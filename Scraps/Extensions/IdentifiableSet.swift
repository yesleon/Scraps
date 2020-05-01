//
//  IdentifiableSet.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

typealias IdentifiableSet<Element: Identifiable> = Dictionary<Element.ID, Element>

extension IdentifiableSet: ExpressibleByArrayLiteral where Value: Identifiable, Value.ID == Key {
    
    mutating func modifyEach(handler: (inout Value) -> Void) {
        for key in keys {
            guard var element = self[key] else { continue }
            handler(&element)
            self[key] = element
        }
    }
    
    mutating func insert(_ value: Value) {
        self[value.id] = value
    }

    
    public init(arrayLiteral elements: Value...) {
        self.init()
        for element in elements {
            self[element.id] = element
        }
    }
    
    init<S: Sequence>(_ elements: S) where S.Element == Value {
        self.init()
        for element in elements {
            self[element.id] = element
        }
    }
    
}
