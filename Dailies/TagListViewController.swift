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
    
    static func makeTagListViewController(thought: Thought, sourceView: UIView, sourceRect: CGRect) -> UIViewController {
        let vc = TagListViewController()
        vc.thoughtIdentifier = thought.date
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController.map {
            $0.delegate = vc
            $0.sourceView = sourceView
            $0.sourceRect = sourceRect
        }
        vc.preferredContentSize = .init(width: 240, height: 360)
        return vc
    }
    
    static func makeNewTagAlert() -> UIViewController {
        let vc = UIAlertController(title: "New Tag", message: nil, preferredStyle: .alert)
        var subscriptions = Set<AnyCancellable>()
        var text = ""
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { _ in
            TagList.shared.modifyValue {
                $0.insert(.init(text))
            }
            subscriptions.removeAll()
        })
        doneAction.isEnabled = false
        vc.addTextField {
            let publisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: $0)
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
        }
        
        [doneAction, .init(title: "Cancel", style: .cancel)].forEach(vc.addAction(_:))
        return vc
    }
    
}

class TagListViewController: UITableViewController {
    
    var thoughtIdentifier: Date?

    override func loadView() {
        let view = TagListView()
        view.controller = self
        view.thoughtIdentifier = thoughtIdentifier
        self.view = view
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }
    
    func didSelectRow(_ row: TagListView.Row) {
        switch row {
        case .newTag:
            present(.makeNewTagAlert(), animated: true)
            
        case .tag(let tag):
            guard let index = ThoughtList.shared.value.firstIndex(where: { $0.date == thoughtIdentifier }) else { return }
            ThoughtList.shared.modifyValue {
                var thought = $0.remove(at: index)
                thought.tags = (thought.tags ?? []).union([tag])
                $0.insert(thought)
            }
        }
    }
    
    func didDeselectRow(_ row: TagListView.Row) {
        guard case let .tag(tag) = row else { return }
        guard let index = ThoughtList.shared.value.firstIndex(where: { $0.date == thoughtIdentifier }) else { return }
        ThoughtList.shared.modifyValue {
            var thought = $0.remove(at: index)
            thought.tags = (thought.tags ?? []).subtracting([tag])
            $0.insert(thought)
        }
    }
    
    func contextMenuConfiguration(for row: TagListView.Row) -> UIContextMenuConfiguration? {
        guard case .tag(let tag) = row else { return nil }
        let deleteAction = UIAction(title: NSLocalizedString("Delete...", comment: ""), attributes: .destructive) { _ in
            
            [UIAlertController(title: "Delete Tag", message: "This will remove the tag from all thoughts.", preferredStyle: .alert)].forEach {
                $0.addAction(.init(title: "Confirm", style: .destructive, handler: { _ in
                    TagList.shared.modifyValue {
                        $0.remove(tag)
                    }
                    let value: [Thought] = ThoughtList.shared.value.map { thought in
                        var thought = thought
                        thought.tags?.remove(tag)
                        return thought
                    }
                    ThoughtList.shared.modifyValue {
                        $0 = Set(value)
                    }
                }))
                $0.addAction(.init(title: "Cancel", style: .cancel))
                self.present($0, animated: true)
            }
            
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "", children: [deleteAction])
        }
    }

}

extension TagListViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
}
