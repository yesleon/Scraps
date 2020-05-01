//
//  AttachmentView.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/5/1.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import LinkPresentation
import PencilKit
import AVFoundation

class AttachmentView: UIView {
    
    var contentSize: CGSize? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        contentSize ?? super.intrinsicContentSize
    }
    
    var attachment: Attachment? {
        didSet {
            subviews.forEach { $0.removeFromSuperview() }
            if let attachment = attachment {
                isHidden = false
                let view = try! attachment.viewThatFits(.init(width: 240.0, height: .infinity))
                contentSize = view.frame.size
                view.frame = bounds
                view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                addSubview(view)
                
            } else {
                isHidden = true
            }
        }
    }

}

extension Attachment {
    
    func viewThatFits(_ size: CGSize) throws -> UIView {
        switch kind {
        case .image:
            let image = UIImage(data: content)!
            let view = UIImageView(image: image)
            view.frame = AVMakeRect(aspectRatio: image.size, insideRect: .init(origin: .zero, size: size))
            view.layer.cornerRadius = 10
            view.layer.masksToBounds = true
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor.systemGray3.cgColor
            return view
        case .linkMetadata:
            let metadata = try NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: content)
            let view = LPLinkView(metadata: metadata!)
            view.bounds.size = view.sizeThatFits(size)
            return view
        case .drawing:
            let drawing = try PKDrawing(data: content)
            let image = drawing.image(from: drawing.bounds.insetBy(dx: -10, dy: -10), scale: UIScreen.main.scale)
            let view = UIImageView(image: image)
            if image.size.width > size.width || image.size.height > size.height {
                view.bounds.size = AVMakeRect(aspectRatio: image.size, insideRect: .init(origin: .zero, size: size)).size
            } else {
                view.bounds.size = image.size
            }
            view.layer.cornerRadius = 10
            view.layer.masksToBounds = true
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor.systemGray3.cgColor
            return view
        }
    }
    
}
