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
        case newTag, tag(Tag.ID)
    }

    var subscriptions = Set<AnyCancellable>()
    
    var scrapIDs = Set<Scrap.ID>()
    
    lazy var diffableDataSource = DataSource(tableView: self) { [weak self] tableView, indexPath, row in
        
        guard let self = self else { return nil }
        switch row {
        case .tag(let tagID):
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? TagListViewCell
            cell?.subscribe(tagID: tagID, scrapIDs: self.scrapIDs)
            return cell
        case .newTag:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewTagCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("New Tag...", comment: "")
            return cell
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.allowsMultipleSelection = true
        self.alwaysBounceVertical = false
        self.separatorStyle = .none
        
        register(TagListViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        register(UITableViewCell.self, forCellReuseIdentifier: "NewTagCell")
        self.dataSource = diffableDataSource
        
        Model.shared.tagsSubject
            .map({
                var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
                snapshot.appendSections([.main])
                snapshot.appendItems($0.keys.map(Row.tag))
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
    }

}
