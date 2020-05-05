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
            SomeScrapsState(vc: vc),
            NoScrapState(vc: vc),
            AllSelectedState(vc: vc),
            SomeSelectedState(vc: vc),
            NoneSelectedState(vc: vc),
        ])
        stateMachine.enter(SomeScrapsState.self)
        
        return stateMachine
    }
    
}


class ScrapListViewControllerState: GKState {
    
    init(vc: ScrapListViewController) {
        self.vc = vc
    }
    
    unowned let vc: ScrapListViewController
    
    var oldSelectedIndexPaths: [IndexPath]?
    var oldIsEditing: Bool?
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        type(of: self) != stateClass
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        if vc.tableView.numberOfSections == 0 {
            stateMachine?.enter(NoScrapState.self)
            oldSelectedIndexPaths = nil
        } else {
            if !vc.isEditing {
                stateMachine?.enter(SomeScrapsState.self)
                oldSelectedIndexPaths = nil
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
    
}

class NotEditingState: ScrapListViewControllerState {
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        vc.navigationItem.rightBarButtonItems = [vc.filterButton]
        vc.navigationItem.leftBarButtonItems = [vc.editButtonItem]
        vc.toolbarItems = [.flexibleSpace(), vc.composeButton]
    }
    
}

final class SomeScrapsState: NotEditingState {
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        vc.editButtonItem.isEnabled = true
        vc.tableView.backgroundView = nil
    }
    
}

final class NoScrapState: NotEditingState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == SomeScrapsState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        vc.editButtonItem.isEnabled = false
        vc.tableView.backgroundView = vc.emptyView
        vc.setEditing(false, animated: true)
    }
    
}

class EditingState: ScrapListViewControllerState {
    
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
    
}

final class AllSelectedState: EditingState {
    
    override var leftBarButtonItems: [UIBarButtonItem] { [vc.editButtonItem, vc.selectNoneButton] }
    
}

final class SomeSelectedState: EditingState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        super.isValidNextState(stateClass) && stateClass != NoScrapState.self
    }
    
}

final class NoneSelectedState: EditingState {
    
    override func setButtonAvailability() {
        vc.deleteButton.isEnabled = false
        vc.tagsButton.isEnabled = false
    }
    
}
