//
//  Scrap.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//


import Foundation

struct Scrap: Codable, Equatable, FileWrapperConvertible {
    typealias Identifier = UUIDIdentifier
    var content: String
    var date: Date
    var tagIDs: Set<Tag.Identifier>
    var attachmentID: Attachment.Identifier?
}

