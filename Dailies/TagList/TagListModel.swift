//
//  TagListModel.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class TagListModel: UITableViewDiffableDataSource<TagListModel.Section, TagListModel.Row> {
    
    enum Section: Hashable, CaseIterable {
        case base, tags
    }

    enum Row: Hashable {
        case noTags, tag(Tag)
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    var tagFilter: TagFilter {
        get {
            Document.shared.tagFilter
        }
        set {
            Document.shared.tagFilter = newValue
        }
    }

    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, row in
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            switch row {
            case .noTags:
                cell.textLabel?.text = "No Tags"
            case .tag(let tag):
                cell.textLabel?.text = tag.title
            }
            return cell
        }
        
        Document.shared.$tags
            .map { $0.map(Row.tag) }
            .sink(receiveValue: { tags in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
                snapshot.appendSections(Section.allCases)
                snapshot.appendItems([.noTags], toSection: .base)
                snapshot.appendItems(tags, toSection: .tags)
                self.apply(snapshot, animatingDifferences: false)
            })
            .store(in: &subscriptions)
    }
}
