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
    override var imageView: UIImageView? { myImageView }
    override var textLabel: UILabel? { myTextLabel }
    override var detailTextLabel: UILabel? { myDetailLabel }
    @IBOutlet weak var linkView: UIView!
    
    var subscriptions = Set<AnyCancellable>()
    var updateCellHeight = { }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myImageView.layer.cornerRadius = 10
    }
    
    func setThoughtID(_ thoughtID: Thought.Identifier) {
        subscriptions.removeAll()
        ThoughtList.shared.$value
            .compactMap({ $0[thoughtID] })
            .sink(receiveValue: { thought in
                self.textLabel?.text = thought.content
                
                self.detailTextLabel?.text = DateFormatter.localizedString(from: thought.date, dateStyle: .none, timeStyle: .short) + " " + thought.tagIDs.compactMap({ TagList.shared.value[$0] }).map(\.title).map({ "#" + $0 }).joined(separator: " ")
            })
            .store(in: &subscriptions)
        
        let width: CGFloat = 200
        
        ThoughtList.shared.$value
            .map({ $0[thoughtID]?.attachmentID })
            .flatMap({ attachmentID -> AnyPublisher<Attachment?, Never> in
                if let attachmentID = attachmentID {
                    AttachmentList.shared.subject.send(.load(attachmentID, targetDimension: width))
                    return AttachmentList.shared.$value
                        .compactMap({ $0[attachmentID] })
                        .eraseToAnyPublisher()
                } else {
                    return Just(nil).eraseToAnyPublisher()
                }
            })
            .removeDuplicates()
            .sink(receiveValue: { attachment in
                if let attachment = attachment {

                    switch attachment.loadedContent {
                    
                    case .image(let image):
                        self.imageView?.isHidden = false
                        self.imageView?.image = image[width]
                        self.linkView.isHidden = true
                    case .linkMetadata(let metadata):
                        self.linkView.subviews.forEach { $0.removeFromSuperview() }
                        if let metadata = metadata {
                            let view = LPLinkView(metadata: metadata)
                            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                            view.frame = self.linkView.bounds
                            self.linkView.addSubview(view)
                            self.linkView.isHidden = false
                        } else {
                            self.linkView.isHidden = true
                        }
                        self.imageView?.isHidden = true
                    }
                } else {
                    self.imageView?.isHidden = true
                    self.linkView.isHidden = true
                }
                self.updateCellHeight()
            })
            .store(in: &subscriptions)
    }

}
