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
    
    func load() {
        var thoughts = Set<Thought>()
        ThoughtList.shared.$value
            .filter({ $0 != thoughts })
            .sink(receiveValue: { newThoughts in
                let oldThoughts = thoughts
                thoughts = newThoughts
                self.undoManager.registerUndo(withTarget: ThoughtList.shared) {
                    $0.modifyValue {
                        $0 = oldThoughts
                    }
                }
            })
            .store(in: &self.subscriptions)
        
        var tags = Set<Tag>()
        TagList.shared.$value
            .filter({ $0 != tags })
            .sink(receiveValue: { newTags in
                let oldTags = tags
                tags = newTags
                self.undoManager.registerUndo(withTarget: TagList.shared) {
                    $0.modifyValue {
                        $0 = oldTags
                    }
                }
            })
            .store(in: &self.subscriptions)
        
        openOrCreateIfFileNotExists()
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
        undoManager.removeAllActions()
    }

    override func contents(forType typeName: String) throws -> Any {
        try JSONEncoder().encode(DocumentData(thoughts: ThoughtList.shared.value, tags: TagList.shared.value))
    }
    
    func openOrCreateIfFileNotExists(completionHandler: ((Bool) -> Void)? = nil) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            open(completionHandler: completionHandler)
        } else {
            save(to: fileURL, for: .forCreating, completionHandler: completionHandler)
        }
    }
}
