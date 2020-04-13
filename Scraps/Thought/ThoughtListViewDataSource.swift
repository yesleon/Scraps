//
//  ThoughtListViewDataSource.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/12.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class ThoughtListViewDataSource: UITableViewDiffableDataSource<DateComponents, Thought.Identifier> {
    
    static func make(tableView: UITableView) -> ThoughtListViewDataSource {
        ThoughtListViewDataSource(tableView: tableView, cellProvider: { tableView, indexPath, thoughtID in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? ThoughtListViewCell else { return nil }
            cell.subscribe(to: ThoughtList.shared.publisher(for: thoughtID))
            cell.attachmentView.sizeChangedHandler = { [weak tableView] in
                tableView?.beginUpdates()
                tableView?.endUpdates()
            }
            return cell
        })
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe() {
        subscriptions.removeAll()
        
        ThoughtList.shared.$value
            .combineLatest(ThoughtFilter.shared.$value, NotificationCenter.default.significantTimeChangeNotificationPublisher())
            .map({ thoughts, filters, _ in
                thoughts.sorted(by: { $0.value.date > $1.value.date })
                    .filter { filters.shouldInclude($0.value) }
                    .reduce([(dateComponents: DateComponents, thoughtIDs: [Thought.Identifier])](), { list, pair in
                        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: pair.value.date)
                        var list = list
                        if list.last?.dateComponents == dateComponents {
                            list[list.index(before: list.endIndex)].thoughtIDs.append(pair.key)
                        } else {
                            list.append((dateComponents: dateComponents, thoughtIDs: [pair.key]))
                        }
                        return list
                    })
            })
            .map({ thoughtsByDates in
                var snapshot = NSDiffableDataSourceSnapshot<DateComponents, Thought.Identifier>()
                thoughtsByDates.forEach {
                    snapshot.appendSections([$0.dateComponents])
                    snapshot.appendItems($0.thoughtIDs, toSection: $0.dateComponents)
                }
                return snapshot
            })
            .receive(on: RunLoop.main)
            .sink { self.apply($0, animatingDifferences: $0.numberOfSections != 0) }
            .store(in: &subscriptions)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
}
