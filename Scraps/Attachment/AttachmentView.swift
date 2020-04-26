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
    
    override var canBecomeFirstResponder: Bool { true }
    
    @Published var contentInsets = UIEdgeInsets.zero
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe<T: Publisher>(to publisherGetter: (CGFloat) -> T, dimension: CGFloat) where T.Output == Attachment?, T.Failure == Never {
        subscriptions.removeAll()
        
        weak var `self` = self
        let publisher = publisherGetter(dimension)
        let imagePublisher = publisherGetter(.maxDimension)
            .compactMap({ attachment -> UIImage? in
                if case let .image(images) = attachment {
                    return images[.maxDimension]
                } else {
                    return nil
                }
            })
            .tryMap({ image -> URL in
                let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
                try image.jpegData(compressionQuality: 0.95)?.write(to: url)
                return url
            })
        
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
                    self.addGestureRecognizer(UITapGestureRecognizer { tapGesture in
                        self.becomeFirstResponder()
                        imagePublisher.map(ImageDataSource.init(url:))
                            .sink(receiveCompletion: { completion in
                                print(completion)
                            }, receiveValue: { dataSource in
                                ImageDataSource.current = dataSource
                                let vc = QLPreviewController()
                                vc.dataSource = dataSource
                                vc.delegate = self
                                self.nearestViewController?.present(vc, animated: true)
                            })
                            .store(in: &self.subscriptions)
                        
                    })
                    
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
        if view is UIImageView {
            view.layer.cornerRadius = 10
            view.layer.masksToBounds = true
            view.contentMode = .scaleAspectFill
        }
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

extension AttachmentView: QLPreviewControllerDelegate {
    
    func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        self.subviews.first(ofType: UIImageView.self)
    }
    
}

private class ImageDataSource: NSObject, QLPreviewControllerDataSource {
    static var current: ImageDataSource?
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        url as NSURL
    }
    
    internal init(url: URL) {
        self.url = url
    }
    
    let url: URL
}

extension UIResponder {
    @objc var nearestViewController: UIViewController? {
        next?.nearestViewController
    }
}

extension UIViewController {
    override var nearestViewController: UIViewController? {
        self
    }
}
