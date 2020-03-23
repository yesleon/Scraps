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
    
    @IBAction func dismiss(segue: UIStoryboardSegue) { }
    
    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        navigationController?.navigationBar.layoutMargins = view.layoutMargins
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        OAuth2.openAuthorizationPage(host: "www.dropbox.com", path: "/oauth2/authorize", clientID: "pjwsk8p4dk374mp", redirectURI: "https://www.narrativesaw.com/auth")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [
                UIAction(title: NSLocalizedString("Copy", comment: "")) { _ in
                    UIPasteboard.general.string = Document.shared.thoughtDayLists[indexPath.section].thoughts[indexPath.row].content
                },
                UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { _ in
                    Document.shared.removeThought(at: indexPath)
                },
            ])
        }
    }

}
