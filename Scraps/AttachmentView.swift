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
    
    fileprivate func makeImageView(size: CGSize, imageGetter: () throws -> UIImage) throws -> UIView {
        var rect: CGRect
        let thumbnail: UIImage
        
        if let image = ThumbnailCache.shared[self] {
            thumbnail = image
            rect = .init(origin: .zero, size: image.size)
        } else {
            let image = try imageGetter()
            if image.size.width > size.width || image.size.height > size.height {
                rect = AVMakeRect(aspectRatio: image.size, insideRect: .init(origin: .zero, size: size))
                rect.origin = .zero
                thumbnail = UIGraphicsImageRenderer(bounds: rect).image { context in
                    image.draw(in: rect)
                }
            } else {
                rect = .init(origin: .zero, size: image.size)
                thumbnail = image
            }
            ThumbnailCache.shared[self] = thumbnail
        }
        
        let view = UIImageView(image: thumbnail)
        view.frame = rect
        
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.systemGray3.cgColor
        return view
    }
    
    func viewThatFits(_ size: CGSize) throws -> UIView {
        switch kind {
        case .image:
            return try makeImageView(size: size) { UIImage(data: self.content)! }
            
        case .linkMetadata:
            let metadata = try NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: content)
            let view = LPLinkView(metadata: metadata!)
            view.bounds.size = view.sizeThatFits(size)
            return view
            
        case .drawing:
            return try makeImageView(size: size) {
                let drawing = try PKDrawing(data: self.content)
                return drawing.image(from: drawing.bounds.insetBy(dx: -10, dy: -10), scale: UIScreen.main.scale)
            }
        }
    }
    
}
