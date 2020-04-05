//
//  TagListViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/4/3.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

extension UIViewController {
    
    static func makeTagListViewController(thoughtID: Thought.Identifier, sourceView: UIView, sourceRect: CGRect) -> UIViewController {
        let vc = TagListViewController()
        vc.thoughtID = thoughtID
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController.map {
            $0.delegate = vc
            $0.sourceView = sourceView
            $0.sourceRect = sourceRect
        }
        vc.preferredContentSize = .init(width: 240, height: 360)
        return vc
    }
    
    static func makeTagNamingAlert(tagID: Tag.Identifier?) -> UIViewController {
        let vc = UIAlertController(title: "Name the Tag", message: nil, preferredStyle: .alert)
        var subscriptions = Set<AnyCancellable>()
        var text = ""
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { _ in
            TagList.shared.modifyValue {
                $0.updateValue(.init(title: text), forKey: tagID ?? .init())
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
        
        [doneAction, .init(title: "Cancel", style: .cancel)].forEach(vc.addAction(_:))
        return vc
    }
    
}

class TagListViewController: UITableViewController {
    
    var thoughtID: Thought.Identifier?

    override func loadView() {
        let view = TagListView()
        view.controller = self
        view.thoughtID = thoughtID
        self.view = view
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }
    
    func didSelectRow(_ row: TagListView.Row) {
        switch row {
        case .newTag:
            present(.makeTagNamingAlert(tagID: nil), animated: true)
            
        case .tag(let tagID):
            guard let thoughtID = thoughtID else { break }
            ThoughtList.shared.modifyValue {
                $0[thoughtID]?.tagIDs.insert(tagID)
            }
        }
    }
    
    func didDeselectRow(_ row: TagListView.Row) {
        guard case let .tag(tagID) = row else { return }
        guard let thoughtID = thoughtID else { return }
        ThoughtList.shared.modifyValue {
            $0[thoughtID]?.tagIDs.remove(tagID)
        }
    }
    
    func contextMenuConfiguration(for row: TagListView.Row) -> UIContextMenuConfiguration? {
        guard case .tag(let tagID) = row else { return nil }
        let renameAction = UIAction(title: "Rename...") { _ in
            self.present(.makeTagNamingAlert(tagID: tagID), animated: true)
        }
        let deleteAction = UIAction(title: NSLocalizedString("Delete...", comment: ""), attributes: .destructive) { _ in
            
            [UIAlertController(title: "Delete Tag", message: "This will remove the tag from all thoughts.", preferredStyle: .alert)].forEach {
                $0.addAction(.init(title: "Confirm", style: .destructive, handler: { _ in
                    TagList.shared.modifyValue {
                        $0.removeValue(forKey: tagID)
                    }
                    ThoughtList.shared.modifyValue { thoughts in
                        thoughts.keys.forEach { key in
                            thoughts[key]?.tagIDs.remove(tagID)
                        }
                    }
                }))
                $0.addAction(.init(title: "Cancel", style: .cancel))
                self.present($0, animated: true)
            }
            
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "", children: [renameAction, deleteAction])
        }
    }

}

extension TagListViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
}
