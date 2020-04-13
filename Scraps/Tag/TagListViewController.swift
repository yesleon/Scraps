//
//  TagListViewController.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/3.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


class TagListViewController: UITableViewController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let dataSource = tableView.dataSource as? TagListView.DataSource else { return nil }
        guard case .tag(let tagID) = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let renameAction = UIAction(title: NSLocalizedString("Rename...", comment: "")) { _ in
            self.present(.tagNamingAlert(tagID: tagID), animated: true)
        }
        let deleteAction = UIAction(title: NSLocalizedString("Delete...", comment: ""), attributes: .destructive) { _ in
            
            [UIAlertController(title: NSLocalizedString("Delete Tag", comment: ""), message: NSLocalizedString("This will remove the tag from all scraps.", comment: ""), preferredStyle: .alert)].forEach {
                $0.addAction(.init(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: { _ in
                    TagList.shared.modifyValue {
                        $0.removeValue(forKey: tagID)
                    }
                    ScrapList.shared.modifyValue { scraps in
                        scraps.keys.forEach { key in
                            scraps[key]?.tagIDs.remove(tagID)
                        }
                    }
                }))
                $0.addAction(.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
                self.present($0, animated: true)
            }
            
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "", children: [renameAction, deleteAction])
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableView = tableView as? TagListView else { return }
        
        guard let row = tableView.diffableDataSource.itemIdentifier(for: indexPath) else { return }
        
        switch row {
        case .newTag:
            present(.tagNamingAlert(tagID: nil), animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            
        case .tag(let tagID):
            
            ScrapList.shared.modifyValue { scraps in
                tableView.scrapIDs.forEach {
                    scraps[$0]?.tagIDs.insert(tagID)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let tableView = tableView as? TagListView else { return }
        
        guard case let .tag(tagID) = tableView.diffableDataSource.itemIdentifier(for: indexPath) else { return }
        
        ScrapList.shared.modifyValue { scraps in
            tableView.scrapIDs.forEach {
                scraps[$0]?.tagIDs.remove(tagID)
            }
        }
    }

}

extension TagListViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
}
