//
//  TagListView.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

@available(iOS 13.0, *)
class TagListView: UITableView {

    var subscriptions = Set<AnyCancellable>()
    var model: TagListModel! {
        dataSource as? TagListModel
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        model.$selection
            .sink(receiveValue: {
                let selectedIndexPaths = self.indexPathsForSelectedRows ?? []
                switch $0 {
                case .noTags:
                    
                    if let indexPath = self.model.indexPath(for: .noTags) {
                        selectedIndexPaths.filter({ $0 != indexPath }).forEach {
                            self.deselectRow(at: $0, animated: false)
                        }
                        if !selectedIndexPaths.contains(indexPath) {
                            self.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        }
                    }
                    
                case .hasTags(let tags):
                    if let indexPath = self.model.indexPath(for: .noTags),
                        selectedIndexPaths.contains(indexPath) {
                        self.deselectRow(at: indexPath, animated: false)
                    }
                    tags.lazy
                        .map(TagListModel.Row.tag)
                        .compactMap(self.model.indexPath(for:))
                        .filter { !selectedIndexPaths.contains($0) }
                        .forEach { self.selectRow(at: $0, animated: false, scrollPosition: .none) }
                }
            })
            .store(in: &subscriptions)
        
        
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        subscriptions.removeAll()
    }

}
