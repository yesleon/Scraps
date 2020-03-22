//
//  ThoughtListViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/23.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class ThoughtListViewController: UITableViewController {
    
    override var canBecomeFirstResponder: Bool { true }
    
    override var undoManager: UndoManager? { Document.shared.undoManager }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if let indexPaths = tableView.indexPathsForSelectedRows, indexPaths.count > 1, indexPaths.contains(indexPath) {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                UIMenu(title: "Multiple selection", children: [
                    UIAction(title: "Copy", handler: { action in
                        UIPasteboard.general.string = indexPaths
                            .map { Document.shared.thoughtDayLists[$0.section].thoughts[$0.row] }
                            .map { $0.content }
                            .reduce("") { $0 + $1 + "\n\n" }
                    }),
                    UIAction(title: "Delete", handler: { action in
                        indexPaths.reversed().forEach(Document.shared.removeThought(at:))
                    })
                ])
            }
        } else {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                UIMenu(title: "", children: [
                    UIAction(title: "Copy", handler: { action in
                        UIPasteboard.general.string = Document.shared.thoughtDayLists[indexPath.section].thoughts[indexPath.row].content
                    }),
                    UIAction(title: "Delete", handler: { action in
                        Document.shared.removeThought(at: indexPath)
                    })
                ])
            }
        }
    }

}
