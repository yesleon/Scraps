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
                case .hasTags(let tagIDs):
                    if !tagIDs.isEmpty {
                        return tagIDs.lazy
                            .compactMap { TagList.shared.value[$0] }
                            .map(\.title)
                            .map({ "#" + $0 })
                            .joined(separator: ", ")
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
    
    func thoughtListView(_ thoughtListView: ThoughtListView, contextMenuConfigurationForThought thoughtID: Thought.Identifier, for indexPath: IndexPath) -> UIContextMenuConfiguration? {
        var actions = [UIAction]()
        guard let thought = ThoughtList.shared.value[thoughtID] else { return nil }
        let url = URL(string: thought.content.trimmingCharacters(in: .whitespacesAndNewlines))
        let shareAction = UIAction(title: "Share") { _ in
            if let url = url {
                [UIActivityViewController(activityItems: [url], applicationActivities: nil)]
                    .forEach { self.present($0, animated: true) }
            } else {
                [UIActivityViewController(activityItems: [thought.content], applicationActivities: nil)]
                    .forEach { self.present($0, animated: true) }
            }
        }
        let tagsAction = UIAction(title: "Tags") { _ in
            self.present(.makeTagListViewController(thoughtID: thoughtID, sourceView: thoughtListView, sourceRect: thoughtListView.rectForRow(at: indexPath)), animated: true)
        }
        let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { _ in
            ThoughtList.shared.modifyValue {
                $0.removeValue(forKey: thoughtID)
            }
        }
        actions = [tagsAction, shareAction, deleteAction]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            UIMenu(title: "", children: actions)
        })
    }
    
}
