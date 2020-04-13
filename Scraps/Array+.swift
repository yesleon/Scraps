//
//  Array+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/13.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//




extension Array {
    
    func first<T>(ofType: T.Type = T.self) -> T? {
        return first(where: { $0 is T }) as? T
    }
    
}
