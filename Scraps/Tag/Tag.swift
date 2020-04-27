//
//  Tag.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation


struct Tag: Codable, Equatable, FileWrapperConvertible {
    struct Identifier: Codable, Hashable, FilenameConvertible {
        var filename: String {
            uuid.uuidString
        }
        
        init?(_ filename: String) {
            guard let uuid = UUID(uuidString: filename) else { return nil }
            self.uuid = uuid
        }
        private let uuid: UUID
        init() {
            uuid = UUID()
        }
    }
    var title: String
}
