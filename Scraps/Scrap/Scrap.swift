//
//  Scrap.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import PencilKit

protocol FilenameConvertible {
    init?(_ filename: String)
    var filename: String { get }
}

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

protocol FileWrapperConvertible {
    init(_ fileWrapper: FileWrapper) throws
    func fileWrapperRepresentation() throws -> FileWrapper
}
extension FileWrapperConvertible where Self: Codable {
    
    init(_ fileWrapper: FileWrapper) throws {
        guard let data = fileWrapper.regularFileContents else { throw "file wrapper no content" }
        self = try JSONDecoder().decode(Self.self, from: data)
    }
    
    func fileWrapperRepresentation() throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)
        return FileWrapper(regularFileWithContents: data)
    }
    
}



extension Dictionary: FileWrapperConvertible where Key: FilenameConvertible, Value: FileWrapperConvertible {
    
    init(_ fileWrapper: FileWrapper) throws {
        guard let fileWrappers = fileWrapper.fileWrappers else { throw "file wrapper no child" }
        var dict = Self()
        for (key, value) in fileWrappers {
            guard let key = Key(key) else { continue }
            dict[key] = try Value(value)
        }
        self = dict
    }
    
    func fileWrapperRepresentation() throws -> FileWrapper {
        var fileWrappers = [String: FileWrapper]()
        for (key, value) in self {
            fileWrappers[key.filename] = try value.fileWrapperRepresentation()
        }
        return FileWrapper(directoryWithFileWrappers: fileWrappers)
    }
    
}

extension Set: FileWrapperConvertible where Element: Codable {
    
}
