//
//  ThoughtListViewController.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/3/23.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

/// Handles user input in `ThoughtListView`.
class ThoughtListViewController: UITableViewController {
    
    @IBOutlet var composeButton: UIBarButtonItem!
    @IBOutlet var tagListButton: UIBarButtonItem!
    @IBOutlet var tagsButton: UIBarButtonItem!
    
    override var canBecomeFirstResponder: Bool { true }
    
    override var undoManager: UndoManager? {
        (UIApplication.shared.delegate as? UIResponder)?.undoManager
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe() {
        subscriptions.removeAll()
        
        ThoughtFilter.shared.$value
            .map({ $0.isEnabled ? UIImage(systemName: "line.horizontal.3.decrease.circle.fill") : UIImage(systemName: "line.horizontal.3.decrease.circle") })
            .assign(to: \.image, on: tagListButton)
            .store(in: &subscriptions)
        
        ThoughtFilter.shared.$value
            .map(\.stringRepresentation)
            .map { $0 ?? NSLocalizedString("All", comment: "") }
            .assign(to: \.title, on: self)
            .store(in: &subscriptions)
        
        Timer.publish(every: 0.1, on: .main, in: .default).autoconnect()
            .filter({ _ in self.presentedViewController == nil })
            .filter({ _ in !self.isFirstResponder })
            .sink(receiveValue: { _ in self.becomeFirstResponder() })
            .store(in: &subscriptions)
    }
    
    // MARK: - Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = true
        (tableView as? ThoughtListView)?.controller = self
        subscribe()
    }
    
    @IBAction func dismiss(segue: UIStoryboardSegue) { }
    
    @IBAction func showTagList(_ button: UIBarButtonItem) {
        guard let tableView = tableView as? ThoughtListView else { return }
        tableView.indexPathsForSelectedRows.map { $0.compactMap { tableView.diffableDataSource.itemIdentifier(for: $0) } }
            .map { present(.tagListViewController(thoughtIDs: Set($0), sourceView: nil, sourceRect: .null, barButtonItem: button), animated: true) }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.beginUpdates()
        tableView.endUpdates()
        navigationItem.setLeftBarButtonItems(editing ? [editButtonItem] : nil, animated: true)
        navigationItem.setRightBarButtonItems(editing ? [tagsButton]: [composeButton, tagListButton], animated: true)
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let diffableDataSource = tableView.dataSource as? ThoughtListViewDataSource else { return nil }
        guard let thoughtID = diffableDataSource.itemIdentifier(for: indexPath) else { return nil }
        guard let thought = ThoughtList.shared.value[thoughtID] else { return nil }
        var actions = [UIAction]()
        let shareAction = UIAction(title: NSLocalizedString("Share", comment: "")) { _ in
            
            [UIActivityViewController(activityItems: [thought.content], applicationActivities: nil)]
                .forEach { self.present($0, animated: true) }
            
        }
        let tagsAction = UIAction(title: NSLocalizedString("Tags", comment: "")) { _ in
            self.present(.tagListViewController(thoughtIDs: [thoughtID], sourceView: tableView, sourceRect: tableView.rectForRow(at: indexPath), barButtonItem: nil), animated: true)
        }
        let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { _ in
            ThoughtList.shared.modifyValue {
                $0.removeValue(forKey: thoughtID)
            }
        }
        actions = [tagsAction, shareAction, deleteAction]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            UIMenu(title: "", children: actions)
        })
    }
    
}