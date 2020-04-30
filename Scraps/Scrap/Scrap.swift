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

struct Scrap0_5: Codable, Equatable, FileWrapperConvertible {
    typealias Identifier = UUIDIdentifier
    var content: String
    var date: Date
    var tagIDs: Set<Tag0_5.Identifier>
    var attachmentID: Attachment.Identifier?
}

extension IdentifiableSet where Element == Scrap {
    
    init(scrapDict: [Scrap0_5.Identifier: Scrap0_5]) {
        self.init()
        scrapDict.forEach {
            self.insert(.init(id: $0.key.uuid, content: $0.value.content, date: $0.value.date, tagIDs: Set($0.value.tagIDs.map(\.uuid)), attachmentID: $0.value.attachmentID))
        }
    }
    
}
