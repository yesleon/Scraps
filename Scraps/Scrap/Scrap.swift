//
//  Scrap.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//


import Foundation



struct Scrap: Codable, Equatable, Identifiable {
    var id: UUID
    var content: String
    var date: Date
    var tagIDs: Set<Tag.ID>
    var attachment: Attachment?
    var todo: Todo?
}

extension Scrap: FileWrapperRepresentable {
    
    init(fileWrapper: FileWrapper) throws {
        let files = fileWrapper.fileWrappers ?? [:]
        self = try JSONDecoder().decode(Scrap.self, from: files["Scrap"]!.regularFileContents!)
        
        if let attachmentFile = files.first(where: { $0.key.hasPrefix("Attachment.") }) {
            if let kind = Attachment.Kind(rawValue: String(attachmentFile.key.dropFirst("Attachment.".count))) {
                self.attachment = .init(kind: kind, content: attachmentFile.value.regularFileContents!)
            }
        }
    }
    
    func fileWrapperRepresentation() throws -> FileWrapper {
        var files = [String: FileWrapper]()
        var scrap = self
        if let attachment = scrap.attachment {
            files["Attachment." + attachment.kind.rawValue] = FileWrapper(regularFileWithContents: attachment.content)
            scrap.attachment = nil
        }
        files["Scrap"] = FileWrapper(regularFileWithContents: try JSONEncoder().encode(self))
        return FileWrapper(directoryWithFileWrappers: files)
    }
    
}
