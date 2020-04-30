//
//  Scrap.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//


import Foundation

struct Scrap: Codable, Equatable, FileWrapperConvertible, Identifiable {
    var id: UUID
    var content: String
    var date: Date
    var tagIDs: Set<Tag.ID>
    var attachmentID: Attachment.Identifier?
}
