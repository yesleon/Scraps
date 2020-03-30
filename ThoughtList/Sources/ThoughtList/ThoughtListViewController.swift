//
//  ThoughtListViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/23.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine


/// Handles user input in `ThoughtListView`.
@available(iOS 13.0, *)
class ThoughtListViewController: UITableViewController {
    @IBOutlet weak var tagListButton: UIBarButtonItem!
    
    override var canBecomeFirstResponder: Bool { true }
    
    override var undoManager: UndoManager? { model.undoManager }
    
    lazy var model = ThoughtListModel(tableView: tableView)
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        becomeFirstResponder()
        tableView.dataSource = model
        
        model.tagFilterPublisher
            .map({ tagFilter in
                if case let .hasTags(tags) = tagFilter {
                    return !tags.isEmpty
                } else {
                    return true
                }
            })
            .compactMap({ $0 ? UIImage(systemName: "book.fill") : UIImage(systemName: "book") })
            .assign(to: \.image, on: tagListButton)
            .store(in: &subscriptions)
        
        model.tagFilterPublisher
            .map({
                switch $0 {
                case .hasTags(let tags):
                    if !tags.isEmpty {
                        
                        return tags.map(\.title).joined(separator: ", ")
                    } else {
                        return "Thoughts"
                    }
                case .noTags:
                    return "No Tags"
                }
            })
            .assign(to: \.title, on: self)
            .store(in: &subscriptions)
    }
    
    @IBAction func dismiss(segue: UIStoryboardSegue) { }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let thought = model.itemIdentifier(for: indexPath) else { return nil }
        let copyAction = UIAction(title: NSLocalizedString("Copy", comment: "")) { _ in
            UIPasteboard.general.string = thought.content
        }
        let tagsAction = UIAction(title: "Tags") { _ in
            [UIAlertController(title: "Tags", message: nil, preferredStyle: .alert)].forEach {
                var textField: UITextField?
                $0.addTextField {
                    textField = $0
                    $0.text = (thought.tags ?? []).map(\.title).joined(separator: ", ")
                }
                $0.addAction(.init(title: "Save", style: .default, handler: { _ in
                    guard let text = textField?.text else { return }
                    var thought = thought
                    let tags = text.split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .map(Tag.init(_:))
                    thought.tags = Set(tags)
                    self.model.insertThought(thought)
                    
                }))
                $0.addAction(.init(title: "Cancel", style: .cancel))
                self.present($0, animated: true)
            }
        }
        let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { _ in
            self.model.removeThought(thought)
            self.undoManager?.setActionName("Delete Thought")
        }
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [copyAction, tagsAction, deleteAction])
        }
    }

}
