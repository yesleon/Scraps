//
//  Scrap.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//


import Foundation

struct Scrap: Codable, Equatable, FileWrapperConvertible {
    struct Identifier: Codable, Hashable, FilenameConvertible {
        init?(_ filename: String) {
            guard let uuid = UUID(uuidString: filename) else { return nil }
            self.uuid = uuid
        }
        var filename: String {
            uuid.uuidString
        }
        
        private let uuid: UUID
        init() {
            uuid = UUID()
        }
    }
    var content: String
    var date: Date
    var tagIDs: Set<Tag.Identifier>
    var attachmentID: Attachment.Identifier?
}

extension String: Error { }



