//
//  Tag.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation


struct Tag: Codable, Hashable {
    struct Identifier: Codable, Hashable {
        let uuid = UUID()
    }
    var title: String
}
