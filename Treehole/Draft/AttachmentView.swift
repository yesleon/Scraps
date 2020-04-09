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
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        Draft.shared.$attachment
            .map { $0 == nil }
            .assign(to: \.isHidden, on: self)
            .store(in: &subscriptions)
        
        Draft.shared.$attachment
            .compactMap { $0 }
            .sink(receiveValue: { attachment in
                self.subviews.forEach { $0.removeFromSuperview() }
                switch attachment {
                case .image(let image):
                    guard let image = image[.maxDimension] else { break }
                    let imageView = UIImageView(image: image)
                    imageView.frame = self.bounds
                    imageView.contentMode = .scaleAspectFill
                    imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    self.addSubview(imageView)
                case .linkMetadata(let metadata):
                    let view = LPLinkView(metadata: metadata)
                    view.frame = self.bounds
                    view.contentMode = .scaleAspectFill
                    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    self.addSubview(view)
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
