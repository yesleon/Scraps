//
//  ThoughtListViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/23.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


/// Handles user input in `ThoughtListView`.
class ThoughtListViewController: UITableViewController {
    
    override var canBecomeFirstResponder: Bool { true }
    
    override var undoManager: UndoManager? { Document.shared.undoManager }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        becomeFirstResponder()
        
        navigationItem.searchController = SearchController(searchResultsController: nil)
        navigationItem.searchController.map {
            $0.searchResultsUpdater = self
            $0.obscuresBackgroundDuringPresentation = false
            $0.delegate = self
        }
    }
    
    @IBAction func dismiss(segue: UIStoryboardSegue) { }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Document.shared.editingThought = Document.shared.sortedThoughts[indexPath.section].thoughts[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let thought = Document.shared.sortedThoughts[indexPath.section].thoughts[indexPath.row]
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [
                UIAction(title: NSLocalizedString("Copy", comment: "")) { _ in
                    UIPasteboard.general.string = thought.content
                },
                UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { _ in
                    
                    Document.shared.thoughts.remove(thought)
                    self.undoManager?.setActionName("Delete Thought")
                },
            ])
        }
    }

}

extension ThoughtListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            Document.shared.filter = {
                $0.content.contains(text)
            }
        } else {
            Document.shared.filter = { _ in true }
        }
    }
    
}

extension ThoughtListViewController: UISearchControllerDelegate {
    
    func didDismissSearchController(_ searchController: UISearchController) {
        becomeFirstResponder()
    }
}
