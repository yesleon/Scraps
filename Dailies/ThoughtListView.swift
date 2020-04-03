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
    
    typealias DataSource =  UITableViewDiffableDataSource<DateComponents, Thought>

    var subscriptions = Set<AnyCancellable>()
    
    var headerViewSubscriptions = [UIView: AnyCancellable]()
    
    @IBOutlet weak var controller: ThoughtListViewController?
    
    lazy var diffableDataSource = DataSource(tableView: self) { tableView, indexPath, thought -> UITableViewCell? in
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = thought.content
        
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: thought.date, dateStyle: .none, timeStyle: .short) + " " + (thought.tags ?? []).map(\.title).map({ "#" + $0 }).joined(separator: " ")
        return cell
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        delegate = self
        dataSource = diffableDataSource
        diffableDataSource.defaultRowAnimation = .fade
        
        register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "reuseIdentifier")
        
        ThoughtList.shared.$value.combineLatest(ThoughtListFilter.shared.$tagFilter)
            .map({ thoughts, tagFilter in
                thoughts.sorted(by: { $0.date > $1.date })
                    .filter({
                        switch tagFilter {
                        case .hasTags(let tags):
                            return tags.isEmpty || ($0.tags ?? []).isSuperset(of: tags)
                        case .noTags:
                            return ($0.tags ?? []).isEmpty
                        }
                    })
                    .reduce([(dateComponents: DateComponents, thoughts: [Thought])](), { list, thought in
                        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: thought.date)
                        var list = list
                        if list.last?.dateComponents == dateComponents, var last = list.popLast() {
                            last.thoughts.append(thought)
                            list.append(last)
                        } else {
                            list.append((dateComponents: dateComponents, thoughts: [thought]))
                        }
                        return list
                    })
            })
            .map({ thoughtsByDates in
                var snapshot = NSDiffableDataSourceSnapshot<DateComponents, Thought>()
                thoughtsByDates.forEach {
                    snapshot.appendSections([$0.dateComponents])
                    snapshot.appendItems($0.thoughts, toSection: $0.dateComponents)
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
        guard let thought = diffableDataSource.itemIdentifier(for: indexPath) else { return nil }
        return controller?.thoughtListView(self, contextMenuConfigurationFor: thought, for: indexPath)
    }
    
}
