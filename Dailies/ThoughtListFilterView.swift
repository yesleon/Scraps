//
//  ThoughtListFilterView.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

@available(iOS 13.0, *)
class ThoughtListFilterView: UITableView {
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Row>
    
    enum Section: Hashable {
        case main
    }

    enum Row: Hashable {
        case noTags, tag(Tag.Identifier)
    }
    
    lazy var diffableDataSource = DataSource(tableView: self) { tableView, indexPath, row in
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        switch row {
        case .noTags:
            cell.textLabel?.text = "No Tags"
        case .tag(let tagID):
            guard let tag = TagList.shared.value[tagID] else { break }
            cell.textLabel?.text = "#" + tag.title
        }
        if case .hasTags(let tags) = ThoughtListFilter.shared.tagFilter, case let .tag(tag) = row {
            cell.setSelected(tags.contains(tag), animated: false)
        }
        return cell
    }

    var subscriptions = Set<AnyCancellable>()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.dataSource = diffableDataSource
        
        TagList.shared.$value
            .map { $0.keys.map(Row.tag) }
            .sink(receiveValue: { tags in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
                snapshot.appendSections([.main])
                snapshot.appendItems(tags)
                snapshot.appendItems([.noTags])
                self.diffableDataSource.apply(snapshot, animatingDifferences: false)
            })
            .store(in: &subscriptions)
        
        ThoughtListFilter.shared.$tagFilter
            .sink(receiveValue: {
                let selectedIndexPaths = self.indexPathsForSelectedRows ?? []
                switch $0 {
                case .noTags:
                    
                    if let indexPath = self.diffableDataSource.indexPath(for: .noTags) {
                        selectedIndexPaths.filter({ $0 != indexPath }).forEach {
                            self.deselectRow(at: $0, animated: false)
                        }
                        if !selectedIndexPaths.contains(indexPath) {
                            self.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        }
                    }
                    
                case .hasTags(let tags):
                    if let indexPath = self.diffableDataSource.indexPath(for: .noTags),
                        selectedIndexPaths.contains(indexPath) {
                        self.deselectRow(at: indexPath, animated: false)
                    }
                    tags.lazy
                        .map(Row.tag)
                        .compactMap(self.diffableDataSource.indexPath(for:))
                        .filter { !selectedIndexPaths.contains($0) }
                        .forEach { self.selectRow(at: $0, animated: false, scrollPosition: .none) }
                }
            })
            .store(in: &subscriptions)
        
        
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
    }

}
