//
//  ScrapFilterListViewController.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


@available(iOS 13.0, *)
class ScrapFilterListViewController: UITableViewController, UISearchBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (view as? ScrapFilterListView)?.controller = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Model.shared.scrapFiltersSubject.value.modifyValue(ofType: ScrapFilters.TextFilter.self) {
            if !searchText.isEmpty {
                $0 = .init(text: searchText)
            } else {
                $0 = nil
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let dataSource = tableView.dataSource as? ScrapFilterListView.DataSource else { return nil }
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return row == .text ? nil : indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = tableView.dataSource as? ScrapFilterListView.DataSource else { return }
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch row {
        case .noTags:
            Model.shared.scrapFiltersSubject.value.modifyValue(ofType: ScrapFilters.TagFilter.self) {
                $0 = .noTags
            }
        case .tag(let tag):
            Model.shared.scrapFiltersSubject.value.modifyValue(ofType: ScrapFilters.TagFilter.self) {
                if case .hasTags(var tags) = $0 {
                    tags.insert(tag)
                    $0 = .hasTags(tags)
                } else {
                    $0 = .hasTags([tag])
                }
            }
        case .today:
            Model.shared.scrapFiltersSubject.value.modifyValue(ofType: ScrapFilters.TodayFilter.self) {
                $0 = .init()
            }
        case .attachment(let attachment):
            Model.shared.scrapFiltersSubject.value.modifyValue(ofType: ScrapFilters.AttachmentTypeFilter.self) {
                $0 = .init(attachment: attachment)
            }
        case .text:
            break
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let dataSource = tableView.dataSource as? ScrapFilterListView.DataSource else { return }
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch row {
        case .noTags:
            Model.shared.scrapFiltersSubject.value.modifyValue(ofType: ScrapFilters.TagFilter.self) {
                $0 = .hasTags([])
            }
        case .tag(let tag):
            Model.shared.scrapFiltersSubject.value.modifyValue(ofType: ScrapFilters.TagFilter.self) {
                if case .hasTags(var tags) = $0 {
                    tags.remove(tag)
                    $0 = .hasTags(tags)
                }
            }
        case .today:
            Model.shared.scrapFiltersSubject.value.modifyValue(ofType: ScrapFilters.TodayFilter.self) {
                $0 = nil
            }
            
        case .attachment(_):
            Model.shared.scrapFiltersSubject.value.modifyValue(ofType: ScrapFilters.AttachmentTypeFilter.self) {
                $0 = nil
            }
        case .text:
            break
        }
    }
}

