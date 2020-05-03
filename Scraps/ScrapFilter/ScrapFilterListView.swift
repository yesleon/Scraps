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
    
    var cellSubscriptions = [UITableViewCell: AnyCancellable]()
    
    lazy var diffableDataSource = DataSource(tableView: self) { tableView, indexPath, row in
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        self.cellSubscriptions[cell] = Model.shared.scrapFiltersSubject
            .sink(receiveValue: { [weak self] filters in
                if row != .text {
                    cell.contentView.subviews.filter({ $0 is UISearchBar }).forEach({ $0.removeFromSuperview() })
                }
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
                    guard let tag = Model.shared.tagsSubject.value[tagID] else { break }
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
                case .text:
                    cell.textLabel?.text = nil
                    let searchBar: UISearchBar
                    if let oldSearchBar = cell.contentView.subviews.first(ofType: UISearchBar.self) {
                        searchBar = oldSearchBar
                    } else {
                        searchBar = UISearchBar(frame: cell.bounds)
                        searchBar.searchBarStyle = .minimal
                        searchBar.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                        searchBar.delegate = self?.controller
                        cell.contentView.addSubview(searchBar)
                    }
                    if let filter = filters.first(ofType: ScrapFilters.TextFilter.self) {
                        if searchBar.text != filter.text {
                            searchBar.text = filter.text
                        }
                    } else {
                        searchBar.text = nil
                    }
                    
                case .kind(let kind):
                    let filter = ScrapFilters.KindFilter(kind: kind)
                    let selected = filter == filters.first(ofType: ScrapFilters.KindFilter.self)
                    cell.textLabel?.text = filter.stringRepresentation
                    cell.imageView?.image = filter.imageRepresentation(selected: selected)
                    if selected {
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    } else {
                        tableView.deselectRow(at: indexPath, animated: false)
                    }
                case .todo(let todo):
                    let filter = ScrapFilters.TodoFilter(todo: todo)
                    cell.textLabel?.text = filter.stringRepresentation
                    if filter == filters.first(ofType: ScrapFilters.TodoFilter.self) {
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    } else {
                        tableView.deselectRow(at: indexPath, animated: false)
                    }
                }
            })
        
        
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
                if !tags.isEmpty {
                    snapshot.appendItems(tags)
                    snapshot.appendItems([.noTags])
                }
                snapshot.appendItems(Attachment.Kind.allCases.map(Row.kind))
                snapshot.appendItems([Row.kind(nil)])
                snapshot.appendItems([Row.todo(.anytime), Row.todo(.done)])
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
