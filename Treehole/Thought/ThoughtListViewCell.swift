//
//  ThoughtListViewCell.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/7.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import LinkPresentation
import Combine

class ThoughtListViewCell: UITableViewCell {

    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myTextLabel: UILabel!
    @IBOutlet weak var myDetailLabel: UILabel!
    @IBOutlet weak var linkView: UIView!
    
    var subscriptions = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myImageView.layer.cornerRadius = 10
    }
    
    func setThoughtID(_ thoughtID: Thought.Identifier) {
        
        // Clean up
        subscriptions.removeAll()
        linkView.subviews.forEach { $0.removeFromSuperview() }
        linkView.isHidden = true
        myImageView.isHidden = true
        
        let thoughtPublisher = ThoughtList.shared.publisher(for: thoughtID)
        
        // Content
        thoughtPublisher
            .map(\.content)
            .map(Optional.init)
            .assign(to: \.text, on: myTextLabel)
            .store(in: &subscriptions)
        
        // Metadata
        thoughtPublisher
            .combineLatest(TagList.shared.$value)
            .map({ thought, tags -> String? in
                DateFormatter.localizedString(from: thought.date, dateStyle: .none, timeStyle: .short)
                    + " "
                    + thought.tagIDs
                        .compactMap { tags[$0] }
                        .map(\.title)
                        .map({ "#" + $0 })
                        .joined(separator: " ")
            })
            .assign(to: \.text, on: myDetailLabel)
            .store(in: &subscriptions)
        

        // Attachment
        
        thoughtPublisher
            .compactMap(\.attachmentID)
            .flatMap { AttachmentList.shared.publisher(for: $0, targetDimension: .itemWidth) }
            .removeDuplicates()
            .sink(receiveValue: { [weak self] attachment in
                guard let self = self else { return }
                switch attachment {
                case .image(let image):
                    self.myImageView?.isHidden = false
                    self.myImageView?.image = image[.itemWidth]
                    
                case .linkMetadata(let metadata):
                    self.linkView.isHidden = false
                    let view = LPLinkView(metadata: metadata)
                    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    view.frame = self.linkView.bounds
                    self.linkView.addSubview(view)
                }
            })
            .store(in: &subscriptions)
    }

}
