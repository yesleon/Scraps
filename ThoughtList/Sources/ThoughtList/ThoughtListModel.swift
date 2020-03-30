//
//  ThoughtListModel.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/27.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine
import MainModel

@available(iOS 13.0, *)
typealias Tag = MainModel.Tag

@available(iOS 13.0, *)
class ThoughtListModel: UITableViewDiffableDataSource<DateComponents, Thought> {
    
    var subscriptions = Set<AnyCancellable>()
    
    var undoManager: UndoManager { Document.shared.undoManager }
    
    var tagFilterPublisher: Published<TagFilter>.Publisher {
        Document.shared.$tagFilter
    }

    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, thought -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            cell.textLabel?.text = thought.content
            
            cell.detailTextLabel?.text = DateFormatter.localizedString(from: thought.date, dateStyle: .none, timeStyle: .short) + " " + (thought.tags ?? []).map(\.title).joined(separator: ", ")
            return cell
        }
        self.defaultRowAnimation = .fade
        
        Document.shared.$thoughts
            .combineLatest(Document.shared.$tagFilter)
            .map({ tuple in
                tuple.0
                    .filter({ thought in
                        switch tuple.1 {
                        case .noTags:
                            return thought.tags?.isEmpty != false
                        case .hasTags(let tags):
                            return tags.isEmpty || tags.isSubset(of: thought.tags ?? [])
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
            })
            .sink(receiveValue: { [weak self] thoughts in
                guard let self = self else { return }
                
                var snapshot = NSDiffableDataSourceSnapshot<DateComponents, Thought>()
                thoughts.forEach {
                    snapshot.appendSections([$0.dateComponents])
                    snapshot.appendItems($0.thoughts, toSection: $0.dateComponents)
                }
                self.apply(snapshot, animatingDifferences: self.snapshot().numberOfSections != 0)
            })
            .store(in: &subscriptions)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Calendar.current.date(from: snapshot().sectionIdentifiers[section])
            .map { DateFormatter.localizedString(from: $0, dateStyle: .full, timeStyle: .none) }
    }
    
    func removeThought(_ thought: Thought) {
        Document.shared.thoughts.remove(thought)
    }
    
    func insertThought(_ thought: Thought) {
        var thoughts = Document.shared.thoughts
        if let thought = thoughts.first(where: { $0.date == thought.date }) {
            thoughts.remove(thought)
        }
        thoughts.insert(thought)
        Document.shared.thoughts = thoughts
        
        thought.tags?.forEach {
            if !Document.shared.tags.contains($0) {
                Document.shared.tags.append($0)
            }
        }
    }
}
