//
//  AttachmentView.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/7.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine
import LinkPresentation

class AttachmentView: UIView {
    
    var subscriptions = Set<AnyCancellable>()
    weak var imageView: UIView?
    weak var linkView: UIView?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        Draft.shared.$attachment
            .map { $0 == nil }
            .assign(to: \.isHidden, on: self)
            .store(in: &subscriptions)
        
        Draft.shared.$attachment
            .compactMap { $0 }
            .sink(receiveValue: { attachment in
                self.imageView?.removeFromSuperview()
                self.linkView?.removeFromSuperview()
                switch attachment {
                case .image(let image):
                    guard let image = image[.maxDimension] else { break }
                    let imageView = UIImageView(image: image)
                    imageView.frame = CGRect(x: 20, y: 8, width: 200 * image.size.width / image.size.height, height: 200)
                    imageView.layer.cornerRadius = 10
                    imageView.layer.masksToBounds = true
                    imageView.contentMode = .scaleAspectFill
                    imageView.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
                    self.insertSubview(imageView, at: 0)
                    self.imageView = imageView
                case .linkMetadata(let metadata):
                    let view = LPLinkView(metadata: metadata)
                    view.frame = CGRect(x: 20, y: 8, width: 200, height: 200)
                    view.contentMode = .scaleAspectFill
                    view.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
                    self.insertSubview(view, at: 0)
                    self.linkView = view
                    if metadata.title == nil, let url = metadata.originalURL {
                        LPMetadataProvider().startFetchingMetadata(for: url) { metadata, error in
                            DispatchQueue.main.async {
                                guard let metadata = metadata else { return }
                                view.metadata = metadata
                            }
                        }
                    }
                }
            })
            .store(in: &subscriptions)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
    }

}
