//
//  Tag.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation


struct Tag: Codable, Equatable, FileWrapperConvertible, Identifiable {
    var id: UUID
    var title: String
}
