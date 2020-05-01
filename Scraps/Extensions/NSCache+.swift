//
//  NSCache+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/5/1.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class ThumbnailCache {
    
    static let shared = ThumbnailCache()
    
    private let store = NSCache<NSObject, UIImage>()
    private var table = [Attachment: NSObject]()
    
    subscript(attachment: Attachment) -> UIImage? {
        get {
            guard let key = table[attachment] else { return nil }
            return store.object(forKey: key)
        }
        set {
            if let image = newValue {
                let key = NSObject()
                table[attachment] = key
                store.setObject(image, forKey: key)
            } else {
                if let key = table[attachment] {
                    store.removeObject(forKey: key)
                    table[attachment] = nil
                }
            }
        }
    }
    
}
