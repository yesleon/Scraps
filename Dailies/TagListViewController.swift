//
//  TagListViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class TagListViewController: UITableViewController {
    
    enum Section: Hashable, CaseIterable {
        case base, tags
    }
    
    enum Row: Hashable {
        case noTags, tag(Tag)
    }
    
    lazy var dataSource = UITableViewDiffableDataSource<Section, Row>(tableView: tableView) { tableView, indexPath, row in
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        switch row {
        case .noTags:
            cell.textLabel?.text = "No Tags"
        case .tag(let tag):
            cell.textLabel?.text = tag.title
        }
        return cell
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.modalPresentationStyle = .popover
        self.popoverPresentationController?.delegate = self
        self.preferredContentSize = .init(width: 240, height: 360)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Document.shared.$tags
            .map { $0.map(Row.tag) }
            .sink(receiveValue: { tags in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
                snapshot.appendSections(Section.allCases)
                snapshot.appendItems([.noTags], toSection: .base)
                snapshot.appendItems(tags, toSection: .tags)
                self.dataSource.apply(snapshot, animatingDifferences: false)
            })
            .store(in: &subscriptions)
        
        switch Document.shared.tagFilter {
        case .noTags:
            self.dataSource.indexPath(for: .noTags)
                .map { tableView.selectRow(at: $0, animated: false, scrollPosition: .none) }
        case .hasTags(let tags):
            tags.lazy
                .map(Row.tag)
                .compactMap { self.dataSource.indexPath(for: $0) }
                .forEach { tableView.selectRow(at: $0, animated: false, scrollPosition: .none) }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        dataSource.itemIdentifier(for: indexPath).map {
            switch $0 {
            case .noTags:
                Document.shared.tagFilter = .hasTags([])
            case .tag(let tag):
                if case .hasTags(var tags) = Document.shared.tagFilter {
                    tags.remove(tag)
                    Document.shared.tagFilter = .hasTags(tags)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSource.itemIdentifier(for: indexPath).map {
            switch $0 {
            case .noTags:
                Document.shared.tagFilter = .noTags
                tableView.indexPathsForSelectedRows?.filter { $0 != indexPath }.forEach {
                    tableView.deselectRow(at: $0, animated: false)
                }
            case .tag(let tag):
                dataSource.indexPath(for: .noTags).map {
                    tableView.deselectRow(at: $0, animated: false)
                }
                if case .hasTags(var tags) = Document.shared.tagFilter {
                    tags.insert(tag)
                    Document.shared.tagFilter = .hasTags(tags)
                } else {
                    Document.shared.tagFilter = .hasTags([tag])
                }
            }
            
        }
    }
}

extension TagListViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
}
