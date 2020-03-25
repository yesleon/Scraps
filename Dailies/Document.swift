//
//  Document.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

//enum Diff {
//    case newIndexPath(IndexPath), newSection(Int), removeIndexPath(IndexPath), removeSection(Int)
//}

class Document: UIDocument {
    
    enum Error: Swift.Error {
        case contentsNotData(Any)
    }
    
    static let shared = Document(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("data"))
    
    @Published var draft: String?
    
    @Published var thoughts = Set<Thought>()
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { throw Error.contentsNotData(contents) }
        thoughts = try JSONDecoder().decode(Set<Thought>.self, from: data)
    }
    
    override func contents(forType typeName: String) throws -> Any {
        try JSONEncoder().encode(thoughts)
    }
    
    override func open(completionHandler: ((Bool) -> Void)? = nil) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            super.open(completionHandler: completionHandler)
        } else {
            save(to: fileURL, for: .forCreating, completionHandler: completionHandler)
        }
    }
    
}
