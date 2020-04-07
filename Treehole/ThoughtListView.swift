//
//  ThoughtListView.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine
import func AVFoundation.AVMakeRect

class ThoughtListView: UITableView {
    
    class DataSource: UITableViewDiffableDataSource<DateComponents, Thought.Identifier> {
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            true
        }
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    
    lazy var diffableDataSource = DataSource(tableView: self) { tableView, indexPath, thoughtID -> UITableViewCell? in
        tableView.layoutIfNeeded()
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? ThoughtListViewCell
        
        cell?.setThoughtID(thoughtID)
            
        
        
        return cell
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        dataSource = diffableDataSource
        diffableDataSource.defaultRowAnimation = .fade
        
        register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "reuseIdentifier")
        
        ThoughtList.shared.$value
            .combineLatest(ThoughtFilter.shared.$value, NotificationCenter.default.significantTimeChangeNotificationPublisher())
            .map({ thoughts, filters, _ in
                thoughts.sorted(by: { $0.value.date > $1.value.date })
                    .filter { filters.shouldInclude($0.value) }
                    .reduce([(dateComponents: DateComponents, thoughtIDs: [Thought.Identifier])](), { list, pair in
                        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: pair.value.date)
                        var list = list
                        if list.last?.dateComponents == dateComponents, var last = list.popLast() {
                            last.thoughtIDs.append(pair.key)
                            list.append(last)
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
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [dataSource = diffableDataSource] snapshot in
                dataSource.apply(snapshot, animatingDifferences: snapshot.numberOfSections != 0)
            })
            .store(in: &subscriptions)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
    }
    
}
