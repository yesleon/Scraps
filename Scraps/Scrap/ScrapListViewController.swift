//
//  ScrapListViewController.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/3/23.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import GameplayKit



/// Handles user input in `ScrapListView`.
class ScrapListViewController: UITableViewController {
    
    @IBOutlet var composeButton: UIBarButtonItem!
    @IBOutlet var filterButton: UIBarButtonItem!
    @IBOutlet var tagsButton: UIBarButtonItem!
    
    
    lazy var selectNoneButton = UIBarButtonItem(title: "Select None", style: .plain) { [unowned vc = self] button in
        vc.tableView.indexPathsForAllRows.forEach { vc.tableView.deselectRow(at: $0, animated: false) }
    }
    
    lazy var selectAllButton = UIBarButtonItem(title: "Select All", style: .plain) { [unowned vc = self] button in
        vc.tableView.indexPathsForAllRows.forEach { vc.tableView.selectRow(at: $0, animated: false, scrollPosition: .none) }
    }
    
    lazy var deleteButton = UIBarButtonItem(barButtonSystemItem: .trash) { [unowned vc = self] button in
        modify(&Model.shared.scrapsSubject.value) { scraps in
            vc.tableView.indexPathsForSelectedRows?.forEach { indexPath in
                guard let diffableDataSource = vc.tableView.dataSource as? ScrapListViewDataSource else { return }
                guard let scrapID = diffableDataSource.itemIdentifier(for: indexPath) else { return }
                scraps[scrapID] = nil
            }
        }
    }
    
    
    override var canBecomeFirstResponder: Bool { true }
    
    override var undoManager: UndoManager? {
        myUndoManager
    }
    
    var subscriptions = Set<AnyCancellable>()
    
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
        
        let stateMachine = GKStateMachine.forScrapListViewController(self)
        CADisplayLink.publisher(in: .main, forMode: .common)
            .sink(receiveValue: { _ in
                stateMachine.update(deltaTime: 0)
            })
            .store(in: &subscriptions)
    }
    
    // MARK: - Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = true
        (tableView as? ScrapListView)?.controller = self
        subscribe()
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
