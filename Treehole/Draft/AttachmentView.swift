//
//  AttachmentView.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/7.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import LinkPresentation

class AttachmentView: UIView {
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe<T: Publisher>(to publisher: T) where T.Output == Attachment?, T.Failure == Never {
        subscriptions.removeAll()
        
        weak var imageView: UIView?
        weak var linkView: UIView?
        weak var `self` = self
        
        publisher
            .map { $0 == nil }
            .assign(to: \.isHidden, on: self)
            .store(in: &subscriptions)
        
        publisher
            .compactMap { $0 }
            .sink(receiveValue: { attachment in
                imageView?.removeFromSuperview()
                linkView?.removeFromSuperview()
                switch attachment {
                case .image(let image):
                    guard let image = image[.maxDimension] else { break }
                    let view = UIImageView(image: image)
                    view.frame = CGRect(x: 20, y: 8, width: 200 * image.size.width / image.size.height, height: 200)
                    view.layer.cornerRadius = 10
                    view.layer.masksToBounds = true
                    view.contentMode = .scaleAspectFill
                    view.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
                    self?.insertSubview(view, at: 0)
                    imageView = view
                case .linkMetadata(let metadata):
                    let view = LPLinkView(metadata: metadata)
                    view.frame = CGRect(x: 20, y: 8, width: 200, height: 200)
                    view.contentMode = .scaleAspectFill
                    view.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
                    self?.insertSubview(view, at: 0)
                    linkView = view
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
    
    // MARK: - Events
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if subscriptions.isEmpty {
            subscribe(to: Draft.shared.$attachment)
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
    }

}
