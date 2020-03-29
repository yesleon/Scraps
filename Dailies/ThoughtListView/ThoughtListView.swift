//
//  ThoughtListView.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine


/// Display the Model. Is synced with it.
/// Using a diffable data source object to do diff.
class ThoughtListView: UITableView {
    
    var subscriptions = Set<AnyCancellable>()
    lazy var diffableDataSource = ThoughtListViewDataSource(tableView: self)
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        dataSource = diffableDataSource
        Document.shared.$sortedThoughts
            .sink(receiveValue: { [weak self] thoughts in
                guard let self = self else { return }
                var snapshot = self.diffableDataSource.snapshot()
                snapshot.deleteAllItems()
                thoughts.forEach {
                    snapshot.appendSections([$0.dateComponents])
                    snapshot.appendItems($0.thoughts, toSection: $0.dateComponents)
                }
                self.diffableDataSource.apply(snapshot)
                
                thoughts.last
                    .flatMap { $0.thoughts.last }
                    .flatMap(self.diffableDataSource.indexPath(for:))
                    .map { self.scrollToRow(at: $0, at: .bottom, animated: true) }
            })
            .store(in: &subscriptions)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
    }
    
}
