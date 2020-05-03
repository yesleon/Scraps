//
//  Tag.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation



struct Tag: Codable, Equatable, Identifiable {
    var id: UUID
    var title: String
}

extension IdentifiableSet where Key == Tag.ID, Value == Tag {
    
    init(fileWrapper: FileWrapper) throws {
        self = try JSONDecoder().decode(Self.self, from: fileWrapper.regularFileContents!)
    }
    
    func fileWrapperRepresentation() throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: try JSONEncoder().encode(self))
    }
    
}
