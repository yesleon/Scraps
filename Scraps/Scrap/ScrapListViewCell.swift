//
//  ScrapListViewCell.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/7.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import LinkPresentation
import Combine


class ScrapListViewCell: UITableViewCell {

    @IBOutlet weak var attachmentView: AttachmentView!
    @IBOutlet weak var myTextLabel: UILabel!
    @IBOutlet weak var myDetailLabel: UILabel!
    @IBOutlet weak var todoButton: UIButton! {
        didSet {
            todoButton.addAction(for: .touchUpInside) { [weak self] button in
                guard let self = self else { return }
                self.todoButtonTapped(cell: self)
            }
        }
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe<T: Publisher>(to publisher: T) where T.Output == Scrap, T.Failure == Never {
        subscriptions.removeAll()
        
        // Content
        publisher
            .map(\.content)
            .map(Optional.init)
            .assign(to: \.text, on: myTextLabel)
            .store(in: &subscriptions)
        
        publisher
            .map(\.content)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: \.isHidden, on: myTextLabel)
            .store(in: &subscriptions)
        
        // Metadata
        publisher
            .combineLatest(Model.shared.tagsSubject, { scrap, tags in
                (scrap, scrap.tagIDs.compactMap { tags[$0] })
            })
            .map({ (scrap: Scrap, tags: [Tag]) -> String? in
                DateFormatter.localizedString(from: scrap.date, dateStyle: .none, timeStyle: .short)
                    + " "
                    + tags.map(\.title).map({ "#" + $0 }).joined(separator: " ")
            })
            .assign(to: \.text, on: myDetailLabel)
            .store(in: &subscriptions)
        
        publisher
            .compactMap(\.todo)
            .compactMap({ todo -> UIImage? in
                switch todo {
                case .anytime:
                    return UIImage(systemName: "square")
                case .done:
                    return UIImage(systemName: "checkmark.square.fill")
                }
            })
            .sink(receiveValue: { [weak self] image in
                self?.todoButton.setImage(image, for: .normal)
            })
            .store(in: &subscriptions)
        
        publisher
            .map { $0.todo == nil }
            .assign(to: \.isHidden, on: todoButton)
            .store(in: &subscriptions)
        

        // Attachment
        
        publisher
            .map(\.attachment)
            .assign(to: \.attachment, on: attachmentView)
            .store(in: &subscriptions)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        attachmentView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        let vc = AttachmentViewController()
        attachmentView.controller = vc
        vc.insertIntoViewControllerHierarchy(vc)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        subscriptions.removeAll()
        attachmentView.controller?.willMove(toParent: nil)
        attachmentView.controller?.removeFromParent()
    }

}

extension UIResponder {
    
    @objc func todoButtonTapped(cell: UITableViewCell) {
        next?.todoButtonTapped(cell: cell)
    }
    
}
