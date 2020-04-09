//
//  ThoughtListViewController.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/3/23.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

/// Handles user input in `ThoughtListView`.
@available(iOS 13.0, *)
class ThoughtListViewController: UITableViewController {
    
    @IBOutlet var composeButton: UIBarButtonItem!
    @IBOutlet var tagListButton: UIBarButtonItem!
    @IBOutlet var tagsButton: UIBarButtonItem!
    
    override var canBecomeFirstResponder: Bool { true }
    
    var subscriptions = Set<AnyCancellable>()
    
    var headerViewSubscriptions = [UIView: AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
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
    
    
    
    @IBAction func dismiss(segue: UIStoryboardSegue) { }
    
    @IBAction func showTagList(_ button: UIBarButtonItem) {
        guard let tableView = tableView as? ThoughtListView else { return }
        
        tableView.indexPathsForSelectedRows
            .map { $0.compactMap { tableView.diffableDataSource.itemIdentifier(for: $0) } }
            .map(Set.init)
            .map({
                present(.makeTagListViewController(thoughtIDs: $0, sourceView: nil, sourceRect: .null, barButtonItem: button), animated: true)
            })
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        tableView.beginUpdates()
        super.setEditing(editing, animated: animated)
        tableView.endUpdates()
        if editing {
            navigationItem.setLeftBarButtonItems([editButtonItem], animated: true)
            navigationItem.setRightBarButtonItems([tagsButton], animated: true)
        } else {
            navigationItem.setLeftBarButtonItems(nil, animated: true)
            navigationItem.setRightBarButtonItems([composeButton, tagListButton], animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    override func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        self.setEditing(true, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if ThoughtFilter.shared.value.first(ofType: TodayFilter.self) != nil {
            return 0
        } else {
            return tableView.sectionHeaderHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let diffableDataSource = tableView.dataSource as? ThoughtListView.DataSource else { return nil }
        let dateComponents = diffableDataSource.snapshot().sectionIdentifiers[section]
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "reuseIdentifier") else { return nil }
        
        headerViewSubscriptions[view] = NotificationCenter.default.significantTimeChangeNotificationPublisher()
            .map { dateComponents }
            .compactMap(Calendar.current.date(from:))
            .sink(receiveValue: { date in
                let formatter = DateFormatter()
                formatter.doesRelativeDateFormatting = true
                formatter.dateStyle = .full
                formatter.timeStyle = .none
                view.textLabel?.text = formatter.string(from: date)
                view.textLabel?.sizeToFit()
            })
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let diffableDataSource = tableView.dataSource as? ThoughtListView.DataSource else { return nil }
        guard let thoughtID = diffableDataSource.itemIdentifier(for: indexPath) else { return nil }
        var actions = [UIAction]()
        guard let thought = ThoughtList.shared.value[thoughtID] else { return nil }
        let shareAction = UIAction(title: NSLocalizedString("Share", comment: "")) { _ in
            
            [UIActivityViewController(activityItems: [thought.content], applicationActivities: nil)]
                    .forEach { self.present($0, animated: true) }
            
        }
        let tagsAction = UIAction(title: NSLocalizedString("Tags", comment: "")) { _ in
            self.present(.makeTagListViewController(thoughtIDs: [thoughtID], sourceView: tableView, sourceRect: tableView.rectForRow(at: indexPath), barButtonItem: nil), animated: true)
        }
        let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { _ in
            ThoughtList.shared.modifyValue {
                $0.removeValue(forKey: thoughtID)
            }
            thought.attachmentID.map {
                AttachmentList.shared.subject.send(.delete($0))
            }
        }
        actions = [tagsAction, shareAction, deleteAction]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            UIMenu(title: "", children: actions)
        })
    }
    
}
