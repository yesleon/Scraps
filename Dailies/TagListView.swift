//
//  TagListView.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/4/3.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class TagListView: UITableView {
    
    enum Section: Hashable {
        case main
    }
    
    enum Row: Hashable {
        case newTag, tag(Tag.Identifier)
    }

    var subscriptions = Set<AnyCancellable>()
    var cellSubscriptions = [UITableViewCell: AnyCancellable]()
    
    lazy var diffableDataSource = UITableViewDiffableDataSource<Section, Row>(tableView: self) { tableView, indexPath, row in
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        switch row {
        case .tag(let tagID):
            self.cellSubscriptions[cell] = TagList.shared.$value.combineLatest(ThoughtList.shared.$value)
                .sink(receiveValue: { tags, thoughts in
                    guard let tag = tags[tagID] else { return }
                    cell.textLabel?.text = tag.title
                    if let thoughtID = self.thoughtID, let thought = thoughts[thoughtID],
                        thought.tagIDs.contains(tagID) {
                        cell.imageView?.image = UIImage(systemName: "tag.fill")
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    } else {
                        cell.imageView?.image = UIImage(systemName: "tag")
                        tableView.deselectRow(at: indexPath, animated: false)
                    }
                })
            
        case .newTag:
            cell.textLabel?.text = "New Tag..."
            tableView.deselectRow(at: indexPath, animated: false)
        }
        return cell
    }
    
    var thoughtID: Thought.Identifier?
    
    weak var controller: TagListViewController?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.allowsMultipleSelection = true
        self.alwaysBounceVertical = false
        self.separatorStyle = .none
        
        register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.dataSource = diffableDataSource
        self.delegate = self
        
        TagList.shared.$value
            .map(\.keys)
            .map({
                var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
                snapshot.appendSections([.main])
                snapshot.appendItems(Array($0).map(Row.tag))
                snapshot.appendItems([.newTag])
                return snapshot
            })
            .sink(receiveValue: { [diffableDataSource] in
                diffableDataSource.apply($0)
            })
            .store(in: &subscriptions)
        
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
        cellSubscriptions.removeAll()
    }

}

extension TagListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let dataSource = tableView.dataSource as? UITableViewDiffableDataSource<Section, Row> else { return nil }
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return controller?.contextMenuConfiguration(for: row)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        controller?.didSelectRow(row)
        if row == .newTag {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let row = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        controller?.didDeselectRow(row)
    }
    
}
