//
//  TagListModel.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine
import MainModel


@available(iOS 13.0, *)
extension UIViewController {
    public static func tagsVC(selection: TagFilter, selectionSetter: @escaping (TagFilter) -> Void, sourceView: UIView) -> UIViewController {
        let vc: TagListViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "TagsVC")
        vc.model = TagListModel(tableView: vc.tableView, selection: selection, selectionSetter: selectionSetter, showNoTags: false)
        vc.modalPresentationStyle = .popover
        class PopoverDelegate: NSObject, UIPopoverPresentationControllerDelegate {
            static let shared = PopoverDelegate()
            func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
                .none
            }
        }
        vc.popoverPresentationController.map {
            $0.delegate = PopoverDelegate.shared
            $0.sourceView = sourceView
            $0.sourceRect = sourceView.bounds
        }
        vc.preferredContentSize = .init(width: 240, height: 360)
        return vc
    }
}

@available(iOS 13.0, *)
class TagListModel: UITableViewDiffableDataSource<TagListModel.Section, TagListModel.Row> {
    
    enum Section: Hashable, CaseIterable {
        case base, tags
    }

    enum Row: Hashable {
        case noTags, tag(Tag)
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    @Published var selection: TagFilter {
        didSet {
            selectionSetter(selection)
        }
    }
    private let selectionSetter: (TagFilter) -> Void

    init(tableView: UITableView, selection: TagFilter = Document.shared.tagFilter, selectionSetter: @escaping (TagFilter) -> Void = { Document.shared.tagFilter = $0 }, showNoTags: Bool = true) {
        self.selection = selection
        self.selectionSetter = selectionSetter
        super.init(tableView: tableView) { tableView, indexPath, row in
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            switch row {
            case .noTags:
                cell.textLabel?.text = "No Tags"
                cell.imageView?.image = nil
            case .tag(let tag):
                cell.textLabel?.text = tag.title
                cell.imageView?.image = UIImage.init(systemName: "tag")
            }
            return cell
        }
        
        Document.shared.$tags
            .map { $0.map(Row.tag) }
            .sink(receiveValue: { tags in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
                if showNoTags {
                    snapshot.appendSections(Section.allCases)
                    snapshot.appendItems([.noTags], toSection: .base)
                } else {
                    snapshot.appendSections([.tags])
                }
                snapshot.appendItems(tags, toSection: .tags)
                self.apply(snapshot, animatingDifferences: false)
            })
            .store(in: &subscriptions)
    }
}
