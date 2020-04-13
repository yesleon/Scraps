//
//  AttachmentView.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/7.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import LinkPresentation
import PencilKit
import AVFoundation
import QuickLook

class AttachmentView: UIView {
    
    override var intrinsicContentSize: CGSize {
        bounds.size
    }
    
    var sizeChangedHandler = { }
    
    @Published var contentInsets = UIEdgeInsets.zero
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe<T: Publisher>(to publisher: T, dimension: CGFloat) where T.Output == Attachment?, T.Failure == Never {
        subscriptions.removeAll()
        
        weak var `self` = self
        
        $contentInsets.assign(to: \.layoutMargins, on: self)
            .store(in: &subscriptions)
        
        publisher
            .map { $0 == nil }
            .assign(to: \.isHidden, on: self)
            .store(in: &subscriptions)
        
        publisher
            .compactMap { $0 }
            .combineLatest($contentInsets)
            .sink(receiveValue: { attachment, contentInsets in
                guard let self = self else { return }
                
                switch attachment {
                case .image(let image):
                    guard let image = image[dimension] else { break }
                    self.addView(UIImageView(image: image), dimension: dimension, contentInsets: contentInsets)
                    
                case .linkMetadata(let metadata):
                    self.addView(LPLinkView(metadata: metadata), dimension: dimension, contentInsets: contentInsets)
                    
                    if metadata.title == nil, let url = metadata.originalURL {
                        LPMetadataProvider().startFetchingMetadata(for: url) { metadata, error in
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                guard let metadata = metadata else { return }
                                self.addView(LPLinkView(metadata: metadata), dimension: dimension, contentInsets: contentInsets)
                                self.sizeChangedHandler()
                            }
                        }
                    }
                case .drawing(let drawing):
                    UIScreen.main.traitCollection.performAsCurrent {
                        let rect = AVMakeRect(aspectRatio: drawing.bounds.size, insideRect: .init(x: 0, y: 0, width: dimension, height: dimension))
                        let image = UIGraphicsImageRenderer(bounds: rect).image { _ in
                            drawing.image(from: drawing.bounds, scale: UIScreen.main.scale).draw(in: rect)
                        }
                        self.addView(UIImageView(image: image), dimension: dimension, contentInsets: contentInsets)
                    }
                }
            })
            .store(in: &subscriptions)
    }
    
    private func addView(_ view: UIView, dimension: CGFloat, contentInsets: UIEdgeInsets) {
        subviews
            .filter { !($0 is UIControl) }
            .forEach { $0.removeFromSuperview() }
        
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        insertSubview(view, at: 0)
        bounds.size = view.sizeThatFits(.init(width: dimension, height: dimension))
        bounds.size.width += contentInsets.left + contentInsets.right
        bounds.size.height += contentInsets.top + contentInsets.bottom
        view.frame = self.bounds.inset(by: contentInsets)
        view.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Events
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
    }

}
