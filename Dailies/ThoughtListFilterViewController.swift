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
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let dataSource = tableView.dataSource as? ThoughtListFilterView.DataSource else { return nil }
        guard case .tag(let tag) = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { _ in
            UndoManager.main.beginUndoGrouping()
            TagList.shared.modifyValue {
                $0.remove(tag)
            }
            let value: [Thought] = ThoughtList.shared.value.map { thought in
                var thought = thought
                thought.tags?.remove(tag)
                return thought
            }
            ThoughtList.shared.modifyValue {
                $0 = Set(value)
            }
            UndoManager.main.endUndoGrouping()
        }
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [deleteAction])
        }
        
    }
}
