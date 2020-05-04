//
//  ScrapFilterListView.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import PencilKit
import LinkPresentation

@available(iOS 13.0, *)
class ScrapFilterListView: UITableView {
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Row>
    
    enum Section: Hashable {
        case main
    }

    enum Row: Hashable {
        case noTags, tag(Tag.ID), today, text, kind(Attachment.Kind?), todo(Todo)
    }
    
    weak var controller: ScrapFilterListViewController?
    
    lazy var diffableDataSource = DataSource(tableView: self) { tableView, indexPath, row in
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? ScrapFilterListViewCell
        cell?.subscribe(row: row, searchBarDelegate: self.controller)
        return cell
    }

    var subscriptions = Set<AnyCancellable>()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.dataSource = diffableDataSource
        
        Model.shared.tagsSubject
            .map { $0.keys.map(Row.tag) }
            .sink(receiveValue: { tags in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
                snapshot.appendSections([.main])
                snapshot.appendItems([.text])
                snapshot.appendItems([.today])
                snapshot.appendItems([Row.todo(.anytime), Row.todo(.done)])
                snapshot.appendItems([Row.kind(nil)])
                snapshot.appendItems(Attachment.Kind.allCases.map(Row.kind))
                if !tags.isEmpty {
                    snapshot.appendItems([.noTags])
                    snapshot.appendItems(tags)
                }
                self.diffableDataSource.apply(snapshot, animatingDifferences: false)
            })
            .store(in: &subscriptions)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
    }

}
