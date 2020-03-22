//
//  ThoughtListView.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class ThoughtListView: UITableView {
    var subscriptions = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dataSource = Document.shared
        Document.shared.publisher.sink { [weak self] in
            switch $0 {
            case .newIndexPath(let indexPath):
                self?.insertRows(at: [indexPath], with: .fade)
            case .newSection(let section):
                self?.insertSections([section], with: .fade)
            case .removeIndexPath(let indexPath):
                self?.deleteRows(at: [indexPath], with: .fade)
            case .removeSection(let section):
                self?.deleteSections([section], with: .fade)
            } }
            .store(in: &subscriptions)
    }
}
