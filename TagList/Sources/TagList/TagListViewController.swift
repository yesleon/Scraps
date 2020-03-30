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
    
    lazy var model = TagListModel(tableView: tableView)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
        preferredContentSize = .init(width: 240, height: 360)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = model
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        model.itemIdentifier(for: indexPath).map {
            switch $0 {
            case .noTags:
                model.tagFilter = .hasTags([])
            case .tag(let tag):
                if case .hasTags(var tags) = model.tagFilter {
                    tags.remove(tag)
                    model.tagFilter = .hasTags(tags)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.itemIdentifier(for: indexPath).map {
            switch $0 {
            case .noTags:
                model.tagFilter = .noTags
                tableView.indexPathsForSelectedRows?.filter { $0 != indexPath }.forEach {
                    tableView.deselectRow(at: $0, animated: false)
                }
            case .tag(let tag):
                model.indexPath(for: .noTags).map {
                    tableView.deselectRow(at: $0, animated: false)
                }
                if case .hasTags(var tags) = model.tagFilter {
                    tags.insert(tag)
                    model.tagFilter = .hasTags(tags)
                } else {
                    model.tagFilter = .hasTags([tag])
                }
            }
            
        }
    }
}

@available(iOS 13.0, *)
extension TagListViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
}
