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
            .sink(receiveValue: {
                if let attachment = $0 {
                    self.subviews.forEach { $0.removeFromSuperview() }
                    switch attachment {
                    case .image(let image):
                        let imageView = UIImageView(image: image)
                        imageView.frame = self.bounds
                        imageView.contentMode = .scaleAspectFill
                        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                        self.addSubview(imageView)
                    case .link(let url):
                        LPMetadataProvider().startFetchingMetadata(for: url) { metadata, error in
                            DispatchQueue.main.async {
                                guard let metadata = metadata else { return }
                                let view = LPLinkView(metadata: metadata)
                                view.frame = self.bounds
                                view.contentMode = .scaleAspectFill
                                view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                                self.addSubview(view)
                            }
                            
                        }
                    }
                    self.isHidden = false
                } else {
                    self.isHidden = true
                }
            })
            .store(in: &subscriptions)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
    }

}
