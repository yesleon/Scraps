//
//  ThoughtListView.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class ThoughtListView: UITableView, UITableViewDelegate {
    
    lazy var diffableDataSource = ThoughtListViewDataSource.make(tableView: self)
    weak var controller: ThoughtListViewController?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        delegate = self
        register(ThoughtListHeaderView.self, forHeaderFooterViewReuseIdentifier: "reuseIdentifier")
        
        diffableDataSource.defaultRowAnimation = .fade
        diffableDataSource.subscribe()
        dataSource = diffableDataSource
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        DispatchQueue.main.async {
            self.beginUpdates()
            self.endUpdates()
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        diffableDataSource.subscriptions.removeAll()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        controller != nil
    }
    
    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        controller?.setEditing(true, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if ThoughtFilter.shared.value.first(ofType: TodayFilter.self) != nil {
            return 0
        } else {
            return tableView.sectionHeaderHeight
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "reuseIdentifier") as? ThoughtListHeaderView else { return nil }
        view.subscribe(to: diffableDataSource.snapshot().sectionIdentifiers[section])
        return view
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        controller?.tableView(tableView, contextMenuConfigurationForRowAt: indexPath, point: point)
    }
    
}
