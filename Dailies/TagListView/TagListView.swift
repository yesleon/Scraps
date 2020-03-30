//
//  TagListView.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class TagListView: UITableView {

    var subscriptions = Set<AnyCancellable>()
    var diffableDataSource: TagListViewDataSource! {
        dataSource as? TagListViewDataSource
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        
        
        switch Document.shared.tagFilter {
        case .noTags:
            diffableDataSource.indexPath(for: .noTags)
                .map { selectRow(at: $0, animated: false, scrollPosition: .none) }
        case .hasTags(let tags):
            tags.lazy
                .map(Row.tag)
                .compactMap(diffableDataSource.indexPath(for:))
                .forEach { selectRow(at: $0, animated: false, scrollPosition: .none) }
        }
    }

}
