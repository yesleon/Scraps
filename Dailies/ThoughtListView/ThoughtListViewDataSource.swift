//
//  ThoughtListViewDataSource.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/27.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class ThoughtListViewDataSource: UITableViewDiffableDataSource<DateComponents, Thought> {
    
    var subscriptions = Set<AnyCancellable>()

    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, thought -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            cell.textLabel?.text = thought.content
            
            cell.detailTextLabel?.text = DateFormatter.localizedString(from: thought.date, dateStyle: .none, timeStyle: .short) + " " + (thought.tags ?? []).map(\.title).joined(separator: ", ")
            return cell
        }
        self.defaultRowAnimation = .none
        
        Document.shared.$sortedThoughts
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
}
