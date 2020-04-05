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
        case noTags, tag(Tag.Identifier), today
    }
    
    var cellSubscriptions = [UITableViewCell: AnyCancellable]()
    
    lazy var diffableDataSource = DataSource(tableView: self) { tableView, indexPath, row in
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        self.cellSubscriptions[cell] = ThoughtFilter.shared.$value
            .sink(receiveValue: { filters in
                switch row {
                case .noTags:
                    cell.textLabel?.text = "No Tags"
                    cell.imageView?.image = nil
                    
                    if case .noTags = filters.firstElement(ofType: TagFilter.self) {
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    } else {
                        tableView.deselectRow(at: indexPath, animated: false)
                    }
                case .tag(let tagID):
                    guard let tag = TagList.shared.value[tagID] else { break }
                    cell.textLabel?.text = tag.title
                    
                    
                    if case .hasTags(let tagIDs) = filters.firstElement(ofType: TagFilter.self), tagIDs.contains(tagID) {
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        cell.imageView?.image = UIImage(systemName: "tag.fill")
                    } else {
                        tableView.deselectRow(at: indexPath, animated: false)
                        cell.imageView?.image = UIImage(systemName: "tag")
                    }
                    
                case .today:
                    cell.textLabel?.text = "Today"
                    
                    
                    if filters.firstElement(ofType: TodayFilter.self)?.isEnabled == true {
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        cell.imageView?.image = UIImage(systemName: "star.fill")
                    } else {
                        tableView.deselectRow(at: indexPath, animated: false)
                        cell.imageView?.image = UIImage(systemName: "star")
                    }
                }
            })
        
        
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
                snapshot.appendItems([.today])
                snapshot.appendItems(tags)
                snapshot.appendItems([.noTags])
                self.diffableDataSource.apply(snapshot, animatingDifferences: false)
            })
            .store(in: &subscriptions)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
        cellSubscriptions.removeAll()
    }

}
