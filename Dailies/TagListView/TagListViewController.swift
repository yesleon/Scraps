//
//  TagListViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine


enum Section: Hashable, CaseIterable {
    case base, tags
}

enum Row: Hashable {
    case noTags, tag(Tag)
}

class TagListViewController: UITableViewController {
    
    lazy var diffableDataSource = TagListViewDataSource(tableView: tableView)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
        preferredContentSize = .init(width: 240, height: 360)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = diffableDataSource
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        diffableDataSource.itemIdentifier(for: indexPath).map {
            switch $0 {
            case .noTags:
                Document.shared.tagFilter = .hasTags([])
            case .tag(let tag):
                if case .hasTags(var tags) = Document.shared.tagFilter {
                    tags.remove(tag)
                    Document.shared.tagFilter = .hasTags(tags)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        diffableDataSource.itemIdentifier(for: indexPath).map {
            switch $0 {
            case .noTags:
                Document.shared.tagFilter = .noTags
                tableView.indexPathsForSelectedRows?.filter { $0 != indexPath }.forEach {
                    tableView.deselectRow(at: $0, animated: false)
                }
            case .tag(let tag):
                diffableDataSource.indexPath(for: .noTags).map {
                    tableView.deselectRow(at: $0, animated: false)
                }
                if case .hasTags(var tags) = Document.shared.tagFilter {
                    tags.insert(tag)
                    Document.shared.tagFilter = .hasTags(tags)
                } else {
                    Document.shared.tagFilter = .hasTags([tag])
                }
            }
            
        }
    }
}

extension TagListViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
}
