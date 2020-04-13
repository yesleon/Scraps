//
//  ScrapFilterListView.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


@available(iOS 13.0, *)
class ScrapFilterListView: UITableView {
    
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
        self.cellSubscriptions[cell] = ScrapFilterList.shared.$value
            .sink(receiveValue: { filters in
                switch row {
                case .noTags:
                    cell.textLabel?.text = NSLocalizedString("No Tags", comment: "")
                    cell.imageView?.image = nil
                    
                    if case .noTags = filters.first(ofType: ScrapFilters.TagFilter.self) {
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    } else {
                        tableView.deselectRow(at: indexPath, animated: false)
                    }
                case .tag(let tagID):
                    guard let tag = TagList.shared.value[tagID] else { break }
                    cell.textLabel?.text = tag.title
                    
                    
                    if case .hasTags(let tagIDs) = filters.first(ofType: ScrapFilters.TagFilter.self), tagIDs.contains(tagID) {
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        cell.imageView?.image = UIImage(systemName: "tag.fill")
                    } else {
                        tableView.deselectRow(at: indexPath, animated: false)
                        cell.imageView?.image = UIImage(systemName: "tag")
                    }
                    
                case .today:
                    cell.textLabel?.text = NSLocalizedString("Today", comment: "")
                    
                    
                    if filters.first(ofType: ScrapFilters.TodayFilter.self)?.isEnabled == true {
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
                if !tags.isEmpty {
                    snapshot.appendItems(tags)
                    snapshot.appendItems([.noTags])
                }
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
