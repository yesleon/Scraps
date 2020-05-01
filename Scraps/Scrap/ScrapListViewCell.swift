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

    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var myTextLabel: UILabel!
    @IBOutlet weak var myDetailLabel: UILabel!
    
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
        

        // Attachment
        
        publisher
            .map(\.attachment)
            .map { $0 == nil }
            .assign(to: \.isHidden, on: attachmentView)
            .store(in: &subscriptions)
        
        publisher
            .compactMap(\.attachment)
            .compactMap { try? $0.view() }
            .sink(receiveValue: { [weak attachmentView] view in
                guard let attachmentView = attachmentView else { return }
                attachmentView.subviews.forEach { $0.removeFromSuperview() }
                view.frame = attachmentView.bounds
                view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                attachmentView.addSubview(view)
            })
            .store(in: &subscriptions)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        attachmentView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        subscriptions.removeAll()
    }

}
