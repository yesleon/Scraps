//
//  Document.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine
struct DocumentData: Codable {
    var thoughts: [Thought.Identifier: Thought], tags: [Tag.Identifier: Tag]
}

/// The Model. Holds data and publishes data changes. I/O to disk.
/// Converts between disk data structure and data structure in app.
class Document: UIDocument {
    
    var subscriptions = Set<AnyCancellable>()
    
    func load() {
        
        ThoughtList.shared.$value
            .removeDuplicates()
            .scan((oldValue: [Thought.Identifier: Thought](), newValue: [Thought.Identifier: Thought]()), { tuple, newValue in
                return (oldValue: tuple.newValue, newValue: newValue)
            })
            .sink(receiveValue: { tuple in
                self.undoManager.registerUndo(withTarget: ThoughtList.shared) {
                    $0.modifyValue {
                        $0 = tuple.oldValue
                    }
                }
            })
            .store(in: &self.subscriptions)
        
        
        TagList.shared.$value
            .removeDuplicates()
            .scan((oldValue: [Tag.Identifier: Tag](), newValue: [Tag.Identifier: Tag]()), { tuple, newValue in
                return (oldValue: tuple.newValue, newValue: newValue)
            })
            .sink(receiveValue: { tuple in
                self.undoManager.registerUndo(withTarget: TagList.shared) {
                    $0.modifyValue {
                        $0 = tuple.oldValue
                    }
                }
            })
            .store(in: &self.subscriptions)
        
        openOrCreateIfFileNotExists()
    }

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { fatalError() }
        let documentData = try JSONDecoder().decode(DocumentData.self, from: data)
        TagList.shared.modifyValue {
            $0 = documentData.tags
        }
        ThoughtList.shared.modifyValue {
            $0 = documentData.thoughts
        }
        undoManager.removeAllActions()
    }
    
    override func handleError(_ error: Error, userInteractionPermitted: Bool) {
        super.handleError(error, userInteractionPermitted: userInteractionPermitted)
        print(error)
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
