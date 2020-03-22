//
//  Document.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

enum Diff {
    case newIndexPath(IndexPath), newSection(Int)
}

class Document: UIDocument {
private(set) var draft: String?
    
    func saveDraft(_ draft: String) {
        self.draft = draft
    }
    private var thoughtDayLists = [(date: Date, thoughts: [Thought])]()
    var publisher = PassthroughSubject<Diff, Never>()
    
    func addThought(_ content: String) {
        let thought = Thought(content: content, date: Date())
        
        let lastIndex = thoughtDayLists.count - 1
        if !thoughtDayLists.isEmpty,
            Calendar.current.isDate(thought.date, inSameDayAs: thoughtDayLists[lastIndex].date) {
            
            thoughtDayLists[lastIndex].thoughts.append(thought)
            let indexPath = IndexPath(row: thoughtDayLists[lastIndex].thoughts.count-1, section: lastIndex)
            
            publisher.send(.newIndexPath(indexPath))
            
        } else {
            thoughtDayLists.append((date: thought.date, thoughts: [thought]))
            let newSection = thoughtDayLists.count - 1
            
            publisher.send(.newSection(newSection))
        }
    }
}

extension Document: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        thoughtDayLists.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thoughtDayLists[section].thoughts.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = thoughtDayLists[indexPath.section].thoughts[indexPath.row].content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DateFormatter.localizedString(from: thoughtDayLists[section].date, dateStyle: .short, timeStyle: .none)
    }
}
