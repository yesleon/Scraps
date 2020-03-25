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
    private(set) var thoughtDayLists = [(date: Date, thoughts: [Thought])]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        dataSource = ThoughtListViewDataSource.shared
//        Document.shared.publisher.sink { [weak self] in
//            switch $0 {
//            case .newIndexPath(let indexPath):
//                self?.insertRows(at: [indexPath], with: .fade)
//            case .newSection(let section):
//                self?.insertSections([section], with: .fade)
//            case .removeIndexPath(let indexPath):
//                self?.deleteRows(at: [indexPath], with: .fade)
//            case .removeSection(let section):
//                self?.deleteSections([section], with: .fade)
//            } }
//            .store(in: &subscriptions)
    }
}

extension ThoughtListView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        thoughtDayLists.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thoughtDayLists[section].thoughts.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = thoughtDayLists[indexPath.section].thoughts[indexPath.row].content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DateFormatter.localizedString(from: thoughtDayLists[section].date, dateStyle: .full, timeStyle: .none)
    }
}
