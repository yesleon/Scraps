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
    }
    
    @IBAction func dismiss(segue: UIStoryboardSegue) { }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        var thought = Document.shared.sortedThoughts[indexPath.section].thoughts[indexPath.row]
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [
                UIAction(title: NSLocalizedString("Copy", comment: "")) { _ in
                    UIPasteboard.general.string = thought.content
                },
                UIAction(title: "Tags") { _ in
                    [UIAlertController(title: "Tags", message: nil, preferredStyle: .alert)].forEach {
                        var textField: UITextField?
                        $0.addTextField {
                            textField = $0
                            $0.text = (thought.tags ?? []).map({ $0.title }).joined(separator: ", ")
                        }
                        $0.addAction(.init(title: "Save", style: .default, handler: { _ in
                            guard let text = textField?.text else { return }
                            thought.tags = text.split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                .filter { !$0.isEmpty }
                                .map(Tag.init(title:))
                            var thoughts = Document.shared.thoughts
                            if let thought = thoughts.first(where: { $0.date == thought.date }) {
                                thoughts.remove(thought)
                            }
                            thoughts.insert(thought)
                            Document.shared.thoughts = thoughts
                            thought.tags?.forEach {
                                if !Document.shared.tags.contains($0) {
                                    Document.shared.tags.append($0)
                                }
                            }
                        }))
                        $0.addAction(.init(title: "Cancel", style: .cancel))
                        self.present($0, animated: true)
                    }
                },
                UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { _ in
                    
                    Document.shared.thoughts.remove(thought)
                    self.undoManager?.setActionName("Delete Thought")
                },
            ])
        }
    }

}
