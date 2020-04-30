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
        case noTags, tag(Tag.ID), attachment(Attachment?), today, text
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
                case .attachment(let attachment):
                    let filter = ScrapFilters.AttachmentTypeFilter(attachment: attachment)
                    cell.textLabel?.text = filter.stringRepresentation
                    if let currentFilter = filters.first(ofType: ScrapFilters.AttachmentTypeFilter.self), currentFilter.attachment == attachment {
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        cell.imageView?.image = filter.imageRepresentation(selected: true)
                    } else {
                        tableView.deselectRow(at: indexPath, animated: false)
                        cell.imageView?.image = filter.imageRepresentation(selected: false)
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
                    
                }
            })
        
        
        return cell
    }

    var subscriptions = Set<AnyCancellable>()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.dataSource = diffableDataSource
        
        Model.shared.tagsSubject
            .map { $0.map(\.id).map(Row.tag) }
            .sink(receiveValue: { tags in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
                snapshot.appendSections([.main])
                snapshot.appendItems([.text])
                snapshot.appendItems([.today])
                if !tags.isEmpty {
                    snapshot.appendItems(tags)
                    snapshot.appendItems([.noTags])
                }
                snapshot.appendItems([
                    .attachment(.drawing(PKDrawing())),
                    .attachment(.image([:])),
                    .attachment(.linkMetadata(LPLinkMetadata())),
                    .attachment(nil)
                ])
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
