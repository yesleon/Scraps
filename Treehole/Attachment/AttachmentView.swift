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
    
    override var intrinsicContentSize: CGSize {
        bounds.size
    }
    
    var sizeChangedHandler = { }
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe<T: Publisher>(to publisher: T, dimension: CGFloat) where T.Output == Attachment?, T.Failure == Never {
        subscriptions.removeAll()
        
        weak var `self` = self
        
        publisher
            .map { $0 == nil }
            .assign(to: \.isHidden, on: self)
            .store(in: &subscriptions)
        
        publisher
            .compactMap { $0 }
            .sink(receiveValue: { attachment in
                guard let self = self else { return }
                
                self.subviews.forEach { $0.removeFromSuperview() }
                switch attachment {
                case .image(let image):
                    guard let image = image[dimension] else { break }
                    let view = UIImageView(image: image)
                    self.addSubview(view)
                    self.bounds.size = view.sizeThatFits(.init(width: dimension, height: dimension))
                    view.frame = self.bounds
                    view.layer.cornerRadius = 10
                    view.layer.masksToBounds = true
                    view.contentMode = .scaleAspectFill
                    view.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
                    self.invalidateIntrinsicContentSize()
                    
                case .linkMetadata(let metadata):
                    let view = LPLinkView(metadata: metadata)
                    self.addSubview(view)
                    self.bounds.size = view.sizeThatFits(.init(width: dimension, height: dimension))
                    view.frame = self.bounds
                    view.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
                    self.invalidateIntrinsicContentSize()
                    
                    if metadata.title == nil, let url = metadata.originalURL {
                        LPMetadataProvider().startFetchingMetadata(for: url) { metadata, error in
                            DispatchQueue.main.async {
                                guard let metadata = metadata else { return }
                                view.metadata = metadata
                                self.bounds.size = view.sizeThatFits(.init(width: dimension, height: dimension))
                                self.invalidateIntrinsicContentSize()
                                self.sizeChangedHandler()
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
            subscribe(to: Draft.shared.$attachment, dimension: .maxDimension)
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
    }

}
