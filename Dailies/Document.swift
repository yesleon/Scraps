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
    
    @Published var thoughts = [(dateComponents: DateComponents, thoughts: [Thought])]()
    
    private var _thoughts = Set<Thought>() {
        didSet {
            thoughts = sortThoughts(_thoughts)
        }
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { fatalError() }
        _thoughts = try JSONDecoder().decode(Set<Thought>.self, from: data)
    }
    
    override func contents(forType typeName: String) throws -> Any {
        try JSONEncoder().encode(_thoughts)
    }
    
    override func open(completionHandler: ((Bool) -> Void)? = nil) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            super.open(completionHandler: completionHandler)
        } else {
            save(to: fileURL, for: .forCreating, completionHandler: completionHandler)
        }
    }
    
}

func sortThoughts(_ thoughts: Set<Thought>) -> [(dateComponents: DateComponents, thoughts: [Thought])] {
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
    }
}
