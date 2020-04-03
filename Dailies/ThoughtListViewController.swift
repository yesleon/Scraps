//
//  ThoughtListViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/23.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine
import LinkPresentation

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
    
    func thoughtListView(_ thoughtListView: ThoughtListView, contextMenuConfigurationFor thought: Thought, for indexPath: IndexPath) -> UIContextMenuConfiguration? {
        var actions = [UIAction]()
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
            self.present(.makeTagListViewController(thought: thought, sourceView: thoughtListView, sourceRect: thoughtListView.rectForRow(at: indexPath)), animated: true)
        }
        let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { _ in
            ThoughtList.shared.modifyValue {
                $0.remove(thought)
            }
        }
        actions = [tagsAction, shareAction, deleteAction]
        if let url = url {
            let previewAction = UIAction(title: "Preview") { _ in
                LPMetadataProvider().startFetchingMetadata(for: url) { (metadata, error) in
                    DispatchQueue.main.async {
                        metadata.map(LPLinkView.init(metadata:)).map({
                            let vc = UIViewController()
                            vc.view = $0
                            self.present(vc, animated: true)
                        })
                    }
                }
            }
            actions.insert(previewAction, at: 0)
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            UIMenu(title: "", children: actions)
        })
    }
    
}
