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

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: "Delete", handler: { action, sourceView, completion in
                Document.shared.removeThought(at: indexPath)
                completion(true)
            }),
            UIContextualAction(style: .normal, title: "Copy", handler: { action, sourceView, completion in
                UIPasteboard.general.string = Document.shared.thoughtDayLists[indexPath.section].thoughts[indexPath.row].content
                completion(true)
            }),
        ])
    }

}
