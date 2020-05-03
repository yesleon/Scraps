//
//  Sequence+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/5/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

extension Sequence {
    
    func first<T>(ofType: T.Type = T.self) -> T? {
        return first(where: { $0 is T }) as? T
    }
    
    func eraseToAnySequence() -> AnySequence<Element> {
        AnySequence(self)
    }
    
}
