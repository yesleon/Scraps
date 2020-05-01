//
//  NSCache+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/5/1.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

final class Cache<Key: Hashable, Value: NSObject> {
    
    private let store = NSCache<NSObject, Value>()
    private var table = [Key: NSObject]()
    
    subscript(key: Key) -> Value? {
        get {
            guard let objectKey = table[key] else { return nil }
            return store.object(forKey: objectKey)
        }
        set {
            if let image = newValue {
                let objectKey = NSObject()
                table[key] = objectKey
                store.setObject(image, forKey: objectKey)
            } else {
                if let objectKey = table[key] {
                    store.removeObject(forKey: objectKey)
                    table[key] = nil
                }
            }
        }
    }
    
}
