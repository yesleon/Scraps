//
//  ThoughtListView.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine


/// Display the Model. Is synced with it.
/// Using a diffable data source object to do diff.
class ThoughtListView: UITableView {
    
    lazy var diffableDataSource = ThoughtListViewDataSource(tableView: self)
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        dataSource = diffableDataSource
    }
    
}
