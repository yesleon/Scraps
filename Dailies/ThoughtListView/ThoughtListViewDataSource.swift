//
//  ThoughtListViewDataSource.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/27.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


class ThoughtListViewDataSource: UITableViewDiffableDataSource<DateComponents, Thought> {

    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, thought -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            cell.textLabel?.text = thought.content
            
            cell.detailTextLabel?.text = DateFormatter.localizedString(from: thought.date, dateStyle: .none, timeStyle: .short) + " " + (thought.tags ?? []).map({ $0.title }).joined(separator: ", ")
            return cell
        }
        self.defaultRowAnimation = .none
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Calendar.current.date(from: snapshot().sectionIdentifiers[section])
            .map { DateFormatter.localizedString(from: $0, dateStyle: .full, timeStyle: .none) }
    }
}
