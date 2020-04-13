//
//  Tag.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation


struct Tag: Codable, Equatable {
    struct Identifier: Codable, Hashable {
        private let uuid: UUID
        init() {
            uuid = UUID()
        }
    }
    var title: String
}
