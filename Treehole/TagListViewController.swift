//
//  TagListViewController.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/3.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

extension UIViewController {
    
    static func makeTagListViewController(thoughtIDs: Set<Thought.Identifier>, sourceView: UIView?, sourceRect: CGRect, barButtonItem: UIBarButtonItem?) -> UIViewController {
        let vc = TagListViewController()
        let view = TagListView()
        view.thoughtIDs = thoughtIDs
        view.delegate = vc
        vc.view = view
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController.map {
            $0.delegate = vc
            $0.sourceView = sourceView
            $0.sourceRect = sourceRect
            $0.barButtonItem = barButtonItem
        }
        vc.preferredContentSize = .init(width: 240, height: 360)
        return vc
    }
    
    static func makeTagNamingAlert(tagID: Tag.Identifier?) -> UIViewController {
        let vc = UIAlertController(title: NSLocalizedString("Name the Tag", comment: ""), message: nil, preferredStyle: .alert)
        var subscriptions = Set<AnyCancellable>()
        var text = ""
        let doneAction = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { _ in
            TagList.shared.modifyValue {
                $0.updateValue(.init(title: text), forKey: tagID ?? .init(uuid: .init()))
            }
            subscriptions.removeAll()
        })
        doneAction.isEnabled = false
        vc.addTextField { textField in
            let publisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: textField)
                .compactMap { $0.object as? UITextField }
                .compactMap(\.text)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .share()
            
            publisher
                .map(TagList.shared.isTitleValid(_:))
                .assign(to: \.isEnabled, on: doneAction)
                .store(in: &subscriptions)
            
            publisher
                .sink(receiveValue: { text = $0 })
                .store(in: &subscriptions)
            
            TagList.shared.$value
                .sink(receiveValue: {
                    guard let tagID = tagID else { return }
                    guard let tagTitle = $0[tagID]?.title else { return }
                    textField.text = tagTitle
                    textField.placeholder = tagTitle
                })
                .store(in: &subscriptions)
        }
        
        [doneAction, .init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)].forEach(vc.addAction(_:))
        return vc
    }
    
}

class TagListViewController: UITableViewController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let dataSource = tableView.dataSource as? TagListView.DataSource else { return nil }
        guard case .tag(let tagID) = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let renameAction = UIAction(title: NSLocalizedString("Rename...", comment: "")) { _ in
            self.present(.makeTagNamingAlert(tagID: tagID), animated: true)
        }
        let deleteAction = UIAction(title: NSLocalizedString("Delete...", comment: ""), attributes: .destructive) { _ in
            
            [UIAlertController(title: NSLocalizedString("Delete Tag", comment: ""), message: NSLocalizedString("This will remove the tag from all thoughts.", comment: ""), preferredStyle: .alert)].forEach {
                $0.addAction(.init(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: { _ in
                    TagList.shared.modifyValue {
                        $0.removeValue(forKey: tagID)
                    }
                    ThoughtList.shared.modifyValue { thoughts in
                        thoughts.keys.forEach { key in
                            thoughts[key]?.tagIDs.remove(tagID)
                        }
                    }
                }))
                $0.addAction(.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
                self.present($0, animated: true)
            }
            
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "", children: [renameAction, deleteAction])
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableView = tableView as? TagListView else { return }
        
        guard let row = tableView.diffableDataSource.itemIdentifier(for: indexPath) else { return }
        
        switch row {
        case .newTag:
            present(.makeTagNamingAlert(tagID: nil), animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            
        case .tag(let tagID):
            
            ThoughtList.shared.modifyValue { thoughts in
                tableView.thoughtIDs.forEach {
                    thoughts[$0]?.tagIDs.insert(tagID)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let tableView = tableView as? TagListView else { return }
        
        guard case let .tag(tagID) = tableView.diffableDataSource.itemIdentifier(for: indexPath) else { return }
        
        ThoughtList.shared.modifyValue { thoughts in
            tableView.thoughtIDs.forEach {
                thoughts[$0]?.tagIDs.remove(tagID)
            }
        }
    }

}

extension TagListViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
}
