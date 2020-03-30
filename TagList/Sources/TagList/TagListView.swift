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
        
        switch model.tagFilter {
        case .noTags:
            model.indexPath(for: .noTags)
                .map { selectRow(at: $0, animated: false, scrollPosition: .none) }
        case .hasTags(let tags):
            tags.lazy
                .map(TagListModel.Row.tag)
                .compactMap(model.indexPath(for:))
                .forEach { selectRow(at: $0, animated: false, scrollPosition: .none) }
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        subscriptions.removeAll()
    }

}
