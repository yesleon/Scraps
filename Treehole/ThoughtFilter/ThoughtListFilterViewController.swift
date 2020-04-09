//
//  ThoughtListFilterViewController.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


@available(iOS 13.0, *)
class ThoughtListFilterViewController: UITableViewController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = tableView.dataSource as? ThoughtListFilterView.DataSource else { return }
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch row {
        case .noTags:
            ThoughtFilter.shared.modifyValue(ofType: TagFilter.self) {
                $0 = .noTags
            }
        case .tag(let tag):
            ThoughtFilter.shared.modifyValue(ofType: TagFilter.self) {
                if case .hasTags(var tags) = $0 {
                    tags.insert(tag)
                    $0 = .hasTags(tags)
                } else {
                    $0 = .hasTags([tag])
                }
            }
        case .today:
            ThoughtFilter.shared.modifyValue(ofType: TodayFilter.self) {
                $0 = .init()
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let dataSource = tableView.dataSource as? ThoughtListFilterView.DataSource else { return }
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch row {
        case .noTags:
            ThoughtFilter.shared.modifyValue(ofType: TagFilter.self) {
                $0 = .hasTags([])
            }
        case .tag(let tag):
            ThoughtFilter.shared.modifyValue(ofType: TagFilter.self) {
                if case .hasTags(var tags) = $0 {
                    tags.remove(tag)
                    $0 = .hasTags(tags)
                }
            }
        case .today:
            ThoughtFilter.shared.modifyValue(ofType: TodayFilter.self) {
                $0 = nil
            }
            
        }
    }
}
