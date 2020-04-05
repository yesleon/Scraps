//
//  ThoughtListView.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class ThoughtListView: UITableView {
    
    typealias DataSource =  UITableViewDiffableDataSource<DateComponents, Thought.Identifier>

    var subscriptions = Set<AnyCancellable>()
    var cellSubscriptions = [UITableViewCell: AnyCancellable]()
    
    var headerViewSubscriptions = [UIView: AnyCancellable]()
    
    @IBOutlet weak var controller: ThoughtListViewController?
    
    lazy var diffableDataSource = DataSource(tableView: self) { tableView, indexPath, thoughtID -> UITableViewCell? in
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        self.cellSubscriptions[cell] = ThoughtList.shared.$value
            .compactMap({ $0[thoughtID] })
            .sink(receiveValue: { thought in
                cell.textLabel?.text = thought.content
                
                cell.detailTextLabel?.text = DateFormatter.localizedString(from: thought.date, dateStyle: .none, timeStyle: .short) + " " + thought.tagIDs.compactMap({ TagList.shared.value[$0] }).map(\.title).map({ "#" + $0 }).joined(separator: " ")
            })
            
        return cell
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        delegate = self
        dataSource = diffableDataSource
        diffableDataSource.defaultRowAnimation = .fade
        
        register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "reuseIdentifier")
        
        ThoughtList.shared.$value
            .combineLatest(ThoughtListFilter.shared.$tagFilter)
            .map({ thoughts, tagFilter in
                thoughts.sorted(by: { $0.value.date > $1.value.date })
                    .filter({
                        switch tagFilter {
                        case .hasTags(let tagIDs):
                            return tagIDs.isEmpty || $0.value.tagIDs.isSuperset(of: tagIDs)
                        case .noTags:
                            return $0.value.tagIDs.isEmpty
                        }
                    })
                    .reduce([(dateComponents: DateComponents, thoughtIDs: [Thought.Identifier])](), { list, pair in
                        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: pair.value.date)
                        var list = list
                        if list.last?.dateComponents == dateComponents, var last = list.popLast() {
                            last.thoughtIDs.append(pair.key)
                            list.append(last)
                        } else {
                            list.append((dateComponents: dateComponents, thoughtIDs: [pair.key]))
                        }
                        return list
                    })
            })
            .map({ thoughtsByDates in
                var snapshot = NSDiffableDataSourceSnapshot<DateComponents, Thought.Identifier>()
                thoughtsByDates.forEach {
                    snapshot.appendSections([$0.dateComponents])
                    snapshot.appendItems($0.thoughtIDs, toSection: $0.dateComponents)
                }
                return snapshot
            })
            .sink(receiveValue: { [dataSource = diffableDataSource] snapshot in
                dataSource.apply(snapshot, animatingDifferences: dataSource.snapshot().numberOfSections != 0)
            })
            .store(in: &subscriptions)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
    }

}

extension ThoughtListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dateComponents = diffableDataSource.snapshot().sectionIdentifiers[section]
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "reuseIdentifier") else { return nil }
        guard let date = Calendar.current.date(from: dateComponents) else { return nil }
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        headerViewSubscriptions[view] = NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)
            .sink(receiveValue: { _ in
                view.textLabel?.text = formatter.string(from: date)
                view.textLabel?.sizeToFit()
            })
        view.textLabel?.text = formatter.string(from: date)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let thoughtID = diffableDataSource.itemIdentifier(for: indexPath) else { return nil }
        return controller?.thoughtListView(self, contextMenuConfigurationForThought: thoughtID, for: indexPath)
    }
    
}
