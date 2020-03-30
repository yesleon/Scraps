//
//  Document.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine




/// The Model. Holds data and publishes data changes. I/O to disk.
/// Converts between disk data structure and data structure in app.
@available(iOS 13.0, *)
public class Document: UIDocument {

    public static let shared = Document(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("data"))
    
    /// Backing store for `thoughts`.
    public var thoughts = Set<Thought>() {
        didSet {
            undoManager.registerUndo(withTarget: self) {
                $0.thoughts = oldValue
            }
            
            sortThoughts()
        }
    }
    
    func sortThoughts() {
        sortedThoughts = thoughts
            .filter({ thought in
                switch tagFilter {
                case .noTags:
                    return thought.tags?.isEmpty != false
                case .hasTags(let tags):
                    return tags.isEmpty || !tags.isDisjoint(with: thought.tags ?? [])
                }
            })
            .sorted(by: { $0.date > $1.date })
            .reduce([(dateComponents: DateComponents, thoughts: [Thought])](), { list, thought in
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: thought.date)
                var list = list
                if list.last?.dateComponents == dateComponents, var last = list.popLast() {
                    last.thoughts.append(thought)
                    list.append(last)
                } else {
                    list.append((dateComponents: dateComponents, thoughts: [thought]))
                }
                return list
            })
    }
    
    public var tagFilter = TagFilter.hasTags([]) {
        didSet {
            if tagFilter != oldValue {
                sortThoughts()
            }
        }
    }
    
    @Published public var tags = [Tag]()

    /// Data structured for table view.
    @Published private(set) public var sortedThoughts = [(dateComponents: DateComponents, thoughts: [Thought])]()
    

    override public func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { fatalError() }
        thoughts = try JSONDecoder().decode(Set<Thought>.self, from: data)
        undoManager.removeAllActions()
    }

    override public func contents(forType typeName: String) throws -> Any {
        try JSONEncoder().encode(thoughts)
    }

    override public func open(completionHandler: ((Bool) -> Void)? = nil) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            super.open(completionHandler: completionHandler)
        } else {
            save(to: fileURL, for: .forCreating, completionHandler: completionHandler)
        }
    }
}
