//
//  ThoughtListViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/23.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine


/// Handles user input in `ThoughtListView`.
@available(iOS 13.0, *)
class ThoughtListViewController: UITableViewController {
    
    @IBOutlet weak var tagListButton: UIBarButtonItem!
    
    override var canBecomeFirstResponder: Bool { true }
    
    override var undoManager: UndoManager? { .main }
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThoughtListFilter.shared.$tagFilter
            .map({ tagFilter in
                if case let .hasTags(tags) = tagFilter {
                    return !tags.isEmpty
                } else {
                    return true
                }
            })
            .compactMap({ $0 ? UIImage(systemName: "book.fill") : UIImage(systemName: "book") })
            .assign(to: \.image, on: tagListButton)
            .store(in: &subscriptions)

        ThoughtListFilter.shared.$tagFilter
            .map({
                switch $0 {
                case .hasTags(let tags):
                    if !tags.isEmpty {
                        return tags.map(\.title).map({ "#" + $0 }).joined(separator: ", ")
                    } else {
                        return "Thoughts"
                    }
                case .noTags:
                    return "No Tags"
                }
            })
            .assign(to: \.title, on: self)
            .store(in: &subscriptions)
        
        Timer.publish(every: 0.1, on: .main, in: .default).autoconnect()
            .filter({ _ in self.presentedViewController == nil })
            .filter({ _ in !self.isFirstResponder })
            .sink(receiveValue: { _ in self.becomeFirstResponder() })
            .store(in: &subscriptions)
    }
    
    @IBAction func dismiss(segue: UIStoryboardSegue) { }
    
    func contextMenuConfiguration(for thought: Thought, sourceView: UIView) -> UIContextMenuConfiguration? {
        let shareAction = UIAction(title: "Share") { _ in
            [UIActivityViewController(activityItems: [thought.content], applicationActivities: nil)]
                .forEach { self.present($0, animated: true) }
        }
        let tagsAction = UIAction(title: "Tags") { _ in
            self.present(.makeTagListViewController(thought: thought, sourceView: sourceView), animated: true)
        }
        let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { _ in
            ThoughtList.shared.modifyValue {
                $0.remove(thought)
            }
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "", children: [shareAction, tagsAction, deleteAction])
        }
    }

}
