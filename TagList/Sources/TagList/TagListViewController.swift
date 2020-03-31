//
//  TagListViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine


@available(iOS 13.0, *)
class TagListViewController: UITableViewController {
    
    var model: TagListModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = model ?? TagListModel(tableView: tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if case .hasTags(let tags) = model.selection, case let .tag(tag) = model.itemIdentifier(for: indexPath) {
            cell.setSelected(tags.contains(tag), animated: false)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.itemIdentifier(for: indexPath).map {
            switch $0 {
            case .noTags:
                model.selection = .noTags
                
            case .tag(let tag):
                if case .hasTags(var tags) = model.selection {
                    tags.insert(tag)
                    model.selection = .hasTags(tags)
                } else {
                    model.selection = .hasTags([tag])
                }
            case .newTag:
                tableView.deselectRow(at: indexPath, animated: true)
                [UIAlertController(title: "New Tag", message: nil, preferredStyle: .alert)].forEach {
                    var subscriptions = Set<AnyCancellable>()
                    var text = ""
                    let doneAction = UIAlertAction(title: "Done", style: .default, handler: { _ in
                        self.model.insertTag(.init(text))
                        subscriptions.removeAll()
                    })
                    doneAction.isEnabled = false
                    $0.addTextField {
                        let publisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: $0)
                            .compactMap { $0.object as? UITextField }
                            .compactMap(\.text)
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .share()
                        
                        publisher
                            .map { self.model.canInsertTag(.init($0)) }
                            .assign(to: \.isEnabled, on: doneAction)
                            .store(in: &subscriptions)
                        
                        publisher
                            .sink(receiveValue: { text = $0 })
                            .store(in: &subscriptions)
                    }
                    
                    [doneAction, .init(title: "Cancel", style: .cancel)].forEach($0.addAction(_:))
                    
                    present($0, animated: true)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        model.itemIdentifier(for: indexPath).map {
            switch $0 {
            case .noTags:
                model.selection = .hasTags([])
            case .tag(let tag):
                if case .hasTags(var tags) = model.selection {
                    tags.remove(tag)
                    model.selection = .hasTags(tags)
                }
            case .newTag:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if case .tag(let tag) = self.model.itemIdentifier(for: indexPath) {
            let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { _ in
                self.model.deleteTag(tag)
            }
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
                UIMenu(title: "", children: [deleteAction])
            }
        } else {
            return nil
        }
    }
}
