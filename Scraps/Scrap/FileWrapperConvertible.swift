//
//  FileWrapperConvertible.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/27.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation


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


extension Set: FileWrapperConvertible where Element: Codable { }

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
