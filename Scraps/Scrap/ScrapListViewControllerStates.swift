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
    
    unowned let vc: ScrapListViewController
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        type(of: self) != stateClass
    }
    
}

private final class NotEditingState: SelectionState {
    
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
        stateClass == NoneSelectedState.self
    }
    
}

private class EditingState: SelectionState {
    
    var oldSelectedIndexPaths: [IndexPath]?
    
    var leftBarButtonItems: [UIBarButtonItem] { [vc.editButtonItem, vc.selectAllButton] }
    
    func setButtonAvailability() {
        vc.deleteButton.isEnabled = true
        vc.tagsButton.isEnabled = true
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        vc.navigationItem.rightBarButtonItems = [vc.tagsButton]
        vc.navigationItem.leftBarButtonItems = leftBarButtonItems
        vc.toolbarItems = [.flexibleSpace(), vc.deleteButton]
        setButtonAvailability()
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

private final class AllSelectedState: EditingState {
    
    override var leftBarButtonItems: [UIBarButtonItem] { [vc.editButtonItem, vc.selectNoneButton] }
    
}

private final class SomeSelectedState: EditingState { }

private final class NoneSelectedState: EditingState {
    
    override func setButtonAvailability() {
        vc.deleteButton.isEnabled = false
        vc.tagsButton.isEnabled = false
    }
    
}
