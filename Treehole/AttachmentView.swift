//
//  AttachmentView.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/7.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class AttachmentView: UIView {
    
    var subscriptions = Set<AnyCancellable>()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        
        Draft.shared.$attachment
            .sink(receiveValue: {
                if let attachment = $0 {
                    switch attachment {
                    case .image(let image):
                        let imageView = UIImageView(image: image)
                        imageView.frame = self.bounds
                        imageView.contentMode = .scaleAspectFill
                        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                        self.addSubview(imageView)
                    case .link(_):
                        break
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
