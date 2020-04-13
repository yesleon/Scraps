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
                
                self.subviews
                    .filter { !($0 is UIControl) }
                    .forEach { $0.removeFromSuperview() }
                switch attachment {
                case .image(let image):
                    guard let image = image[dimension] else { break }
                    let view = UIImageView(image: image)
                    self.insertSubview(view, at: 0)
                    self.bounds.size = view.sizeThatFits(.init(width: dimension, height: dimension))
                    self.bounds.size.width += contentInsets.left + contentInsets.right
                    self.bounds.size.height += contentInsets.top + contentInsets.bottom
                    view.frame = self.bounds.inset(by: contentInsets)
                    view.layer.cornerRadius = 10
                    view.layer.masksToBounds = true
                    view.contentMode = .scaleAspectFill
                    view.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
                    self.invalidateIntrinsicContentSize()
                    
                case .linkMetadata(let metadata):
                    let view = LPLinkView(metadata: metadata)
                    self.insertSubview(view, at: 0)
                    self.bounds.size = view.sizeThatFits(.init(width: dimension, height: dimension))
                    self.bounds.size.width += contentInsets.left + contentInsets.right
                    self.bounds.size.height += contentInsets.top + contentInsets.bottom
                    view.frame = self.bounds.inset(by: contentInsets)
                    view.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
                    self.invalidateIntrinsicContentSize()
                    
                    if metadata.title == nil, let url = metadata.originalURL {
                        LPMetadataProvider().startFetchingMetadata(for: url) { metadata, error in
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                guard let metadata = metadata else { return }
                                view.metadata = metadata
                                self.bounds.size = view.sizeThatFits(.init(width: dimension, height: dimension))
                                self.bounds.size.width += contentInsets.left + contentInsets.right
                                self.bounds.size.height += contentInsets.top + contentInsets.bottom
                                view.frame = self.bounds.inset(by: contentInsets)
                                self.invalidateIntrinsicContentSize()
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
                        let view = UIImageView(image: image)
                        self.insertSubview(view, at: 0)
                        self.bounds.size = view.sizeThatFits(.init(width: dimension, height: dimension))
                        self.bounds.size.width += contentInsets.left + contentInsets.right
                        self.bounds.size.height += contentInsets.top + contentInsets.bottom
                        view.frame = self.bounds.inset(by: contentInsets)
                        view.layer.cornerRadius = 10
                        view.layer.masksToBounds = true
                        view.contentMode = .scaleAspectFill
                        view.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
                        self.invalidateIntrinsicContentSize()
                    }
                }
            })
            .store(in: &subscriptions)
    }
    
    // MARK: - Events
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
    }

}
