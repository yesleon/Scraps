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
    
    
    lazy var diffableDataSource = DataSource(tableView: self) { tableView, indexPath, thoughtID in
        return Optional(tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath))
            .flatMap { $0 as? ThoughtListViewCell }
            .map({
                $0.setThoughtID(thoughtID)
                return $0
            })
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        dataSource = diffableDataSource
//        prefetchDataSource = self
        diffableDataSource.defaultRowAnimation = .fade
        
        register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "reuseIdentifier")
        
        ThoughtList.shared.publisher()
            .combineLatest(ThoughtFilter.shared.$value,
                           NotificationCenter.default.significantTimeChangeNotificationPublisher())
            .map({ thoughts, filters, _ in
                thoughts
                    .sorted(by: { $0.value.date > $1.value.date })
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
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [dataSource = diffableDataSource] snapshot in
                dataSource.apply(snapshot, animatingDifferences: snapshot.numberOfSections != 0)
            })
            .store(in: &subscriptions)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        DispatchQueue.main.async {
            self.beginUpdates()
            self.endUpdates()
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
    }
    
}

extension ThoughtListView: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.lazy
            .compactMap(diffableDataSource.itemIdentifier(for:))
            .compactMap { ThoughtList.shared.value[$0] }
            .compactMap(\.attachmentID)
            .map { AttachmentList.Message.load($0, targetDimension: .itemWidth) }
            .forEach(AttachmentList.shared.subject.send)
    }
    
}
