//
//  ThoughtListFilterViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

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
            ThoughtListFilter.shared.tagFilter = .noTags
            
        case .tag(let tag):
            if case .hasTags(var tags) = ThoughtListFilter.shared.tagFilter {
                tags.insert(tag)
                ThoughtListFilter.shared.tagFilter = .hasTags(tags)
            } else {
                ThoughtListFilter.shared.tagFilter = .hasTags([tag])
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let dataSource = tableView.dataSource as? ThoughtListFilterView.DataSource else { return }
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        switch row {
        case .noTags:
            ThoughtListFilter.shared.tagFilter = .hasTags([])
        case .tag(let tag):
            if case .hasTags(var tags) = ThoughtListFilter.shared.tagFilter {
                tags.remove(tag)
                ThoughtListFilter.shared.tagFilter = .hasTags(tags)
            }
        }
    }
}
