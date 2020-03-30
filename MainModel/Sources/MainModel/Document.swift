//
//  Document.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

private struct DocumentData: Codable {
    var thoughts: Set<Thought>, tags: [Tag]
}

/// The Model. Holds data and publishes data changes. I/O to disk.
/// Converts between disk data structure and data structure in app.
@available(iOS 13.0, *)
public class Document: UIDocument {

    public static let shared = Document(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("data"))
    
    @Published public var thoughts = Set<Thought>() {
        didSet {
            undoManager.registerUndo(withTarget: self) {
                $0.thoughts = oldValue
            }
        }
    }
    
    @Published public var tagFilter = TagFilter.hasTags([])
    
    @Published public var tags = [Tag]() {
        didSet {
            undoManager.registerUndo(withTarget: self) {
                $0.tags = oldValue
            }
        }
    }

    override public func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { fatalError() }
        let documentData = try JSONDecoder().decode(DocumentData.self, from: data)
        self.thoughts = documentData.thoughts
        self.tags = documentData.tags
        undoManager.removeAllActions()
    }

    override public func contents(forType typeName: String) throws -> Any {
        try JSONEncoder().encode(DocumentData(thoughts: thoughts, tags: tags))
    }

    override public func open(completionHandler: ((Bool) -> Void)? = nil) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            super.open(completionHandler: completionHandler)
        } else {
            save(to: fileURL, for: .forCreating, completionHandler: completionHandler)
        }
    }
}
