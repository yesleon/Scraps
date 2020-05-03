//
//  ScrapListViewController.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/3/23.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

/// Handles user input in `ScrapListView`.
class ScrapListViewController: UITableViewController {
    
    @IBOutlet var composeButton: UIBarButtonItem!
    @IBOutlet var filterButton: UIBarButtonItem!
    @IBOutlet var tagsButton: UIBarButtonItem!
    
    override var canBecomeFirstResponder: Bool { true }
    
    override var undoManager: UndoManager? {
        myUndoManager
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    var attachmentVCs = [ObjectIdentifier: UIViewController]()
    
    func subscribe() {
        subscriptions.removeAll()
        
        Model.shared.scrapFiltersSubject
            .map { UIImage(systemName: $0.isEnabled ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle") }
            .assign(to: \.image, on: filterButton)
            .store(in: &subscriptions)
        
        Model.shared.scrapFiltersSubject
            .map(\.title)
            .map { $0 ?? NSLocalizedString("All", comment: "") }
            .assign(to: \.title, on: self)
            .store(in: &subscriptions)
    }
    
    // MARK: - Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = true
        (tableView as? ScrapListView)?.controller = self
        subscribe()
        setEditing(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        becomeFirstResponder()
    }
    
    @IBAction func dismiss(segue: UIStoryboardSegue) { }
    
    @IBAction func showTagList(_ button: UIBarButtonItem) {
        guard let tableView = tableView as? ScrapListView else { return }
        tableView.indexPathsForSelectedRows
            .map { $0.compactMap { tableView.diffableDataSource.itemIdentifier(for: $0) } }
            .map { present(.tagListViewController(scrapIDs: Set($0), sourceView: nil, sourceRect: .null, barButtonItem: button), animated: true) }
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let diffableDataSource = tableView.dataSource as? ScrapListViewDataSource else { return nil }
        guard let scrapID = diffableDataSource.itemIdentifier(for: indexPath) else { return nil }
        guard let scrap = Model.shared.scrapsSubject.value[scrapID] else { return nil }
        var actions = [UIAction]()
        let todoAction = UIAction(title: scrap.todo == nil ? "Add Todo" : "Remove Todo") { _ in
            Model.shared.scrapsSubject.value[scrapID]?.todo = scrap.todo == nil ? .anytime : nil
        }
        let shareAction = UIAction(title: NSLocalizedString("Share", comment: "")) { _ in
            
            [UIActivityViewController(activityItems: [scrap.content], applicationActivities: nil)]
                .forEach { self.present($0, animated: true) }
            
        }
        let tagsAction = UIAction(title: NSLocalizedString("Tags", comment: "")) { _ in
            self.present(.tagListViewController(scrapIDs: [scrapID], sourceView: tableView, sourceRect: tableView.rectForRow(at: indexPath), barButtonItem: nil), animated: true)
        }
        let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { _ in
            Model.shared.scrapsSubject.value[scrapID] = nil
        }
        actions = [todoAction, tagsAction, shareAction, deleteAction]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            UIMenu(title: "", children: actions)
        })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ScrapListViewCell else { return }
        if attachmentVCs[ObjectIdentifier(cell)] == nil {
            let vc = AttachmentViewController()
            vc.view = cell.attachmentView
            vc.view.addInteraction(UIContextMenuInteraction(delegate: vc))
            addChild(vc)
            attachmentVCs[ObjectIdentifier(cell)] = vc
        }
    }
    
    func tableViewDidChangeSelection(_ tableView: UITableView) {
        let allSelected = Set(tableView.indexPathsForSelectedRows ?? []) == Set(tableView.indexPathsForAllRows)
        if tableView.isEditing {
            
            navigationItem.setRightBarButtonItems([tagsButton], animated: false)
            
            let selectAllButtonItem = UIBarButtonItem(title: "Select All", style: .plain) { button in
                tableView.indexPathsForAllRows.forEach { tableView.selectRow(at: $0, animated: false, scrollPosition: .none) }
            }
            
            let selectNoneButtonItem = UIBarButtonItem(title: "Select None", style: .plain) { button in
                tableView.indexPathsForAllRows.forEach { tableView.deselectRow(at: $0, animated: false) }
            }
            
            navigationItem.setLeftBarButtonItems([editButtonItem, allSelected ? selectNoneButtonItem : selectAllButtonItem], animated: false)
            
            let deleteButtonItem = UIBarButtonItem(barButtonSystemItem: .trash) { button in
                modify(&Model.shared.scrapsSubject.value) { scraps in
                    tableView.indexPathsForSelectedRows?.forEach { indexPath in
                        guard let diffableDataSource = tableView.dataSource as? ScrapListViewDataSource else { return }
                        guard let scrapID = diffableDataSource.itemIdentifier(for: indexPath) else { return }
                        scraps[scrapID] = nil
                    }
                }
            }
            
            toolbarItems = [.flexibleSpace(), deleteButtonItem]
            tagsButton.isEnabled = !(tableView.indexPathsForSelectedRows ?? []).isEmpty
            deleteButtonItem.isEnabled = !(tableView.indexPathsForSelectedRows ?? []).isEmpty
            
        } else {
            navigationItem.setRightBarButtonItems([filterButton], animated: false)
            navigationItem.setLeftBarButtonItems([editButtonItem], animated: false)
            
            toolbarItems = [.flexibleSpace(), composeButton]
        }
        
    }
    
    override func todoButtonTapped(cell: UITableViewCell) {
        guard let diffableDataSource = tableView.dataSource as? ScrapListViewDataSource else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let scrapID = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        modify(&Model.shared.scrapsSubject.value[scrapID]) { scrap in
            guard let todo = scrap?.todo else { return }
            switch todo {
            case .anytime:
                scrap?.todo = .done
            case .done:
                scrap?.todo = .anytime
            }
        }
    }
    
}
