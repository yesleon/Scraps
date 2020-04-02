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
    var thoughts: Set<Thought>, tags: Set<Tag>
}

/// The Model. Holds data and publishes data changes. I/O to disk.
/// Converts between disk data structure and data structure in app.
class Document: UIDocument {
    
    var subscriptions = Set<AnyCancellable>()
    
    override init(fileURL url: URL) {
        super.init(fileURL: url)
        
        undoManager = .main
    }

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { fatalError() }
        let documentData = try JSONDecoder().decode(DocumentData.self, from: data)
        ThoughtList.shared.modifyValue {
            $0 = documentData.thoughts
        }
        TagList.shared.modifyValue {
            $0 = documentData.tags            
        }
        UndoManager.main.removeAllActions()
    }

    override func contents(forType typeName: String) throws -> Any {
        try JSONEncoder().encode(DocumentData(thoughts: ThoughtList.shared.value, tags: TagList.shared.value))
    }
}
