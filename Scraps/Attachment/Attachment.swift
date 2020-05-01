//
//  Attachment.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/5/1.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation


struct Attachment: Equatable, Hashable, Codable {
    enum Kind: String, Codable {
        case image, linkMetadata, drawing
    }
    var kind: Kind
    var content: Data
}
