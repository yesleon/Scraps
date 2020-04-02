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
        
        ThoughtList.shared.$valueByDates.combineLatest(ThoughtListFilter.shared.$tagFilter)
            .map({ thoughtsByDates, tagFilter in
                var snapshot = NSDiffableDataSourceSnapshot<DateComponents, Thought>()
                thoughtsByDates.forEach {
                    let thoughts = $0.thoughts.filter {
                        switch tagFilter {
                        case .hasTags(let tags):
                            return tags.isEmpty || ($0.tags ?? []).isSuperset(of: tags)
                        case .noTags:
                            return ($0.tags ?? []).isEmpty
                        }
                    }
                    if !thoughts.isEmpty {
                        snapshot.appendSections([$0.dateComponents])
                        snapshot.appendItems(thoughts, toSection: $0.dateComponents)
                    }
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
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        return controller?.contextMenuConfiguration(for: thought, sourceView: cell)
    }
    
}
