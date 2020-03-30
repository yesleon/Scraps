//
//  TagListViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine


@available(iOS 13.0, *)
class TagListViewController: UITableViewController {
    
    var model: TagListModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = model ?? TagListModel(tableView: tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.itemIdentifier(for: indexPath).map {
            switch $0 {
            case .noTags:
                model.selection = .noTags
                
            case .tag(let tag):
                if case .hasTags(var tags) = model.selection {
                    tags.insert(tag)
                    model.selection = .hasTags(tags)
                } else {
                    model.selection = .hasTags([tag])
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        model.itemIdentifier(for: indexPath).map {
            switch $0 {
            case .noTags:
                model.selection = .hasTags([])
            case .tag(let tag):
                if case .hasTags(var tags) = model.selection {
                    tags.remove(tag)
                    model.selection = .hasTags(tags)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { _ in
            if case .tag(let tag) = self.model.itemIdentifier(for: indexPath) {
                self.model.deleteTag(tag)
            }
        }
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [deleteAction])
        }
        
    }
}
