//
//  TagListView.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/3.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


class TagListView: UITableView {
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Row>
    
    enum Section: Hashable {
        case main
    }
    
    enum Row: Hashable {
        case newTag, tag(Tag.Identifier)
    }

    var subscriptions = Set<AnyCancellable>()
    var cellSubscriptions = [UITableViewCell: AnyCancellable]()
    
    var scrapIDs = Set<Scrap.Identifier>()
    
    lazy var diffableDataSource = DataSource(tableView: self) { tableView, indexPath, row in
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        switch row {
        case .tag(let tagID):
            self.cellSubscriptions[cell] = TagList.shared.publisher(for: tagID)
                .combineLatest(ScrapList.shared.$value)
                .sink(receiveValue: { tag, scraps in
                    cell.textLabel?.text = tag.title
                    if self.scrapIDs.compactMap({ scraps[$0] })
                        .allSatisfy({ $0.tagIDs.contains(tagID) }) {
                        cell.imageView?.image = UIImage(systemName: "tag.fill")
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    } else {
                        cell.imageView?.image = UIImage(systemName: "tag")
                        tableView.deselectRow(at: indexPath, animated: false)
                    }
                })
            
        case .newTag:
            cell.textLabel?.text = NSLocalizedString("New Tag...", comment: "")
            tableView.deselectRow(at: indexPath, animated: false)
        }
        return cell
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.allowsMultipleSelection = true
        self.alwaysBounceVertical = false
        self.separatorStyle = .none
        
        register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.dataSource = diffableDataSource
        
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
