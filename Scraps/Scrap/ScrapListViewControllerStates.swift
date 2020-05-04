//
//  ScrapListViewControllerStates.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/5/4.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import GameplayKit
import UIKit

extension GKStateMachine {
    
    static func forScrapListViewController(_ vc: ScrapListViewController) -> GKStateMachine {
        let stateMachine = GKStateMachine(states: [
            NotEditingState(vc: vc),
            AllSelectedState(vc: vc),
            SomeSelectedState(vc: vc),
            NoneSelectedState(vc: vc),
        ])
        stateMachine.enter(NotEditingState.self)
        return stateMachine
    }
    
}

private class SelectionState: GKState {
    init(vc: ScrapListViewController) {
        self.vc = vc
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        print(self)
    }
    
    unowned let vc: ScrapListViewController
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return type(of: self) != stateClass
    }
}

private class NotEditingState: SelectionState {
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        vc.navigationItem.rightBarButtonItems = [vc.filterButton]
        vc.navigationItem.leftBarButtonItems = [vc.editButtonItem]
        vc.toolbarItems = [.flexibleSpace(), vc.composeButton]
    }
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        if vc.isEditing {
            stateMachine?.enter(NoneSelectedState.self)
        }
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == NoneSelectedState.self
    }
}

private class EditingState: SelectionState {
    lazy var selectNoneButtonItem = UIBarButtonItem(title: "Select None", style: .plain) { [unowned vc] button in
        vc.tableView.indexPathsForAllRows.forEach { vc.tableView.deselectRow(at: $0, animated: false) }
    }
    lazy var selectAllButtonItem = UIBarButtonItem(title: "Select All", style: .plain) { [unowned vc] button in
        vc.tableView.indexPathsForAllRows.forEach { vc.tableView.selectRow(at: $0, animated: false, scrollPosition: .none) }
    }
    lazy var deleteButtonItem = UIBarButtonItem(barButtonSystemItem: .trash) { [unowned vc] button in
        modify(&Model.shared.scrapsSubject.value) { scraps in
            vc.tableView.indexPathsForSelectedRows?.forEach { indexPath in
                guard let diffableDataSource = self.vc.tableView.dataSource as? ScrapListViewDataSource else { return }
                guard let scrapID = diffableDataSource.itemIdentifier(for: indexPath) else { return }
                scraps[scrapID] = nil
            }
        }
    }
    var oldSelectedIndexPaths: [IndexPath]?
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        let vc = self.vc
        vc.navigationItem.rightBarButtonItems = [vc.tagsButton]
        vc.toolbarItems = [.flexibleSpace(), deleteButtonItem]
    }
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        if !vc.isEditing {
            stateMachine?.enter(NotEditingState.self)
        } else {
            let selectedIndexPaths = vc.tableView.indexPathsForSelectedRows ?? []
            if selectedIndexPaths != oldSelectedIndexPaths {
                if selectedIndexPaths.isEmpty {
                    stateMachine?.enter(NoneSelectedState.self)
                } else if selectedIndexPaths.count != Array(vc.tableView.indexPathsForAllRows).count {
                    stateMachine?.enter(SomeSelectedState.self)
                } else {
                    stateMachine?.enter(AllSelectedState.self)
                }
                oldSelectedIndexPaths = selectedIndexPaths
            }
        }
    }
}

private class AllSelectedState: EditingState {
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        deleteButtonItem.isEnabled = true
        vc.tagsButton.isEnabled = true
        vc.navigationItem.leftBarButtonItems = [vc.editButtonItem, selectNoneButtonItem]
    }
}

private class SomeSelectedState: EditingState {
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        deleteButtonItem.isEnabled = true
        vc.tagsButton.isEnabled = true
        vc.navigationItem.leftBarButtonItems = [vc.editButtonItem, selectAllButtonItem]
    }
}

private class NoneSelectedState: EditingState {
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        deleteButtonItem.isEnabled = false
        vc.tagsButton.isEnabled = false
        vc.navigationItem.leftBarButtonItems = [vc.editButtonItem, selectAllButtonItem]
    }
}
