//
//  ScrapListView.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

private let headerIdentifier = "SectionHeader"

class ScrapListView: UITableView, UITableViewDelegate {
    
    lazy var diffableDataSource = ScrapListViewDataSource.make(tableView: self)
    
    weak var controller: ScrapListViewController?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        delegate = self
        register(ScrapListHeaderView.self, forHeaderFooterViewReuseIdentifier: headerIdentifier)
        
        diffableDataSource.defaultRowAnimation = .fade
        diffableDataSource.subscribe()
        dataSource = diffableDataSource
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        beginUpdates()
        endUpdates()
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
        if Model.shared.scrapFiltersSubject.value.first(ofType: ScrapFilters.TodayFilter.self) != nil {
            return 0
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as? ScrapListHeaderView else { return nil }
        view.subscribe(to: diffableDataSource.snapshot().sectionIdentifiers[section])
        return view
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        controller?.tableView(tableView, contextMenuConfigurationForRowAt: indexPath, point: point)
    }
    
}
