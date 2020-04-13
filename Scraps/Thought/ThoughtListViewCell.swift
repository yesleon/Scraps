//
//  ThoughtListViewCell.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/7.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import LinkPresentation
import Combine


class ThoughtListViewCell: UITableViewCell {

    @IBOutlet weak var attachmentView: AttachmentView!
    @IBOutlet weak var myTextLabel: UILabel!
    @IBOutlet weak var myDetailLabel: UILabel!
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe<T: Publisher>(to publisher: T) where T.Output == Thought, T.Failure == Never {
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
            .combineLatest(TagList.shared.$value, { thought, tags in
                (thought, thought.tagIDs.compactMap { tags[$0] })
            })
            .map({ (thought: Thought, tags: [Tag]) -> String? in
                DateFormatter.localizedString(from: thought.date, dateStyle: .none, timeStyle: .short)
                    + " "
                    + tags.map(\.title).map({ "#" + $0 }).joined(separator: " ")
            })
            .assign(to: \.text, on: myDetailLabel)
            .store(in: &subscriptions)
        

        // Attachment
        
        publisher
            .map(\.attachmentID)
            .map({ id -> AnyPublisher<Attachment?, Never> in
                if let id = id {
                    return AttachmentList.shared.publisher(for: id, targetDimension: .itemWidth).eraseToAnyPublisher()
                } else {
                    return Just(nil).eraseToAnyPublisher()
                }
            })
            .map({ ($0, 200) })
            .sink(receiveValue: attachmentView.subscribe(to:dimension:))
            .store(in: &subscriptions)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        subscriptions.removeAll()
    }

}
