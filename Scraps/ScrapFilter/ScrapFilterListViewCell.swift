//
//  ScrapFilterListViewCell.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/5/4.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class ScrapFilterListViewCell: UITableViewCell {
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe(row: ScrapFilterListView.Row, searchBarDelegate: @autoclosure @escaping () -> UISearchBarDelegate?) {
        Model.shared.scrapFiltersSubject
            .sink(receiveValue: { [weak self] filters in
                guard let cell = self else { return }
                if row != .text {
                    cell.contentView.subviews.filter({ $0 is UISearchBar }).forEach({ $0.removeFromSuperview() })
                }
                switch row {
                case .noTags:
                    cell.textLabel?.text = NSLocalizedString("No Tags", comment: "")
                    cell.imageView?.image = nil
                    
                    if case .noTags = filters.first(ofType: ScrapFilters.TagFilter.self) {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                case .tag(let tagID):
                    guard let tag = Model.shared.tagsSubject.value[tagID] else { break }
                    cell.textLabel?.text = tag.title
                    cell.imageView?.image = UIImage(systemName: "tag")
                    
                    if case .hasTags(let tagIDs) = filters.first(ofType: ScrapFilters.TagFilter.self), tagIDs.contains(tagID) {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                    
                case .today:
                    cell.textLabel?.text = NSLocalizedString("Today", comment: "")
                    cell.imageView?.image = UIImage(systemName: "star")
                    
                    
                    if filters.first(ofType: ScrapFilters.TodayFilter.self)?.isEnabled == true {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
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
                        searchBar.delegate = searchBarDelegate()
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
                    cell.textLabel?.text = filter.title
                    cell.imageView?.image = filter.icon
                    if selected {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                case .todo(let todo):
                    let filter = ScrapFilters.TodoFilter(todo: todo)
                    let selected = filter == filters.first(ofType: ScrapFilters.TodoFilter.self)
                    cell.textLabel?.text = filter.title
                    cell.imageView?.image = filter.icon
                    cell.accessoryType = selected ? .checkmark : .none
                }
            })
            .store(in: &subscriptions)
    }
    
}
