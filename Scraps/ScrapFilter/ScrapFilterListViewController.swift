//
//  ScrapFilterListViewController.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


@available(iOS 13.0, *)
class ScrapFilterListViewController: UITableViewController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = tableView.dataSource as? ScrapFilterListView.DataSource else { return }
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch row {
        case .noTags:
            ScrapFilterList.shared.modifyValue(ofType: ScrapFilters.TagFilter.self) {
                $0 = .noTags
            }
        case .tag(let tag):
            ScrapFilterList.shared.modifyValue(ofType: ScrapFilters.TagFilter.self) {
                if case .hasTags(var tags) = $0 {
                    tags.insert(tag)
                    $0 = .hasTags(tags)
                } else {
                    $0 = .hasTags([tag])
                }
            }
        case .today:
            ScrapFilterList.shared.modifyValue(ofType: ScrapFilters.TodayFilter.self) {
                $0 = .init()
            }
        case .attachment(let attachment):
            ScrapFilterList.shared.modifyValue(ofType: ScrapFilters.AttachmentTypeFilter.self) {
                $0 = .init(attachment: attachment)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let dataSource = tableView.dataSource as? ScrapFilterListView.DataSource else { return }
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch row {
        case .noTags:
            ScrapFilterList.shared.modifyValue(ofType: ScrapFilters.TagFilter.self) {
                $0 = .hasTags([])
            }
        case .tag(let tag):
            ScrapFilterList.shared.modifyValue(ofType: ScrapFilters.TagFilter.self) {
                if case .hasTags(var tags) = $0 {
                    tags.remove(tag)
                    $0 = .hasTags(tags)
                }
            }
        case .today:
            ScrapFilterList.shared.modifyValue(ofType: ScrapFilters.TodayFilter.self) {
                $0 = nil
            }
            
        case .attachment(_):
            ScrapFilterList.shared.modifyValue(ofType: ScrapFilters.AttachmentTypeFilter.self) {
                $0 = nil
            }
        }
    }
}
