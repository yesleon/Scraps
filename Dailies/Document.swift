//
//  Document.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine


class Document: UIDocument {

    static let shared = Document(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("data"))
    
    var thoughtsAsSet: Set<Thought> {
        get {
            Set(thoughts.flatMap { $0.thoughts })
        }
        set {
            let oldValue = thoughtsAsSet
            thoughts = sortThoughts(newValue)
            undoManager.registerUndo(withTarget: self) { $0.thoughtsAsSet = oldValue }
        }
    }

    @Published private(set) var thoughts = [(dateComponents: DateComponents, thoughts: [Thought])]()
    
    @Published var draft: String?

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { fatalError() }
        thoughtsAsSet = try JSONDecoder().decode(Set<Thought>.self, from: data)
        undoManager.removeAllActions()
    }

    override func contents(forType typeName: String) throws -> Any {
        try JSONEncoder().encode(thoughtsAsSet)
    }

    override func open(completionHandler: ((Bool) -> Void)? = nil) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            super.open(completionHandler: completionHandler)
        } else {
            save(to: fileURL, for: .forCreating, completionHandler: completionHandler)
        }
    }
}

private func sortThoughts(_ thoughts: Set<Thought>) -> [(dateComponents: DateComponents, thoughts: [Thought])] {
    thoughts
        .sorted(by: { $0.date < $1.date })
        .reduce([(dateComponents: DateComponents, thoughts: [Thought])]()) { list, thought in
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: thought.date)
            var list = list
            if list.last?.dateComponents == dateComponents, var last = list.popLast() {
                last.thoughts.append(thought)
                list.append(last)
            } else {
                list.append((dateComponents: dateComponents, thoughts: [thought]))
            }
            return list
    }
}
