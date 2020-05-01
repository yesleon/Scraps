//
//  DraftView.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


@available(iOS 13.0, *)
class DraftView: UIView {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var attachmentView: AttachmentView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe() {
        subscriptions.removeAll()
        
        Draft.shared.$value
            .filter { $0 != self.textView.text }
            .assign(to: \.text, on: textView)
            .store(in: &subscriptions)
        
        Draft.shared.$attachment
            .assign(to: \.attachment, on: attachmentView)
            .store(in: &subscriptions)
            
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .map(\.userInfo)
            .compactMap { $0?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .sink(receiveValue: { [weak scrollView] keyboardFrame in
                guard let scrollView = scrollView, let window = scrollView.window, let superview = scrollView.superview else { return }
                superview.layoutIfNeeded()
                let delta = window.bounds.maxY - superview.convert(scrollView.frame, to: window).maxY
                scrollView.contentInset.bottom = keyboardFrame.height - delta
                scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height - delta
            })
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink(receiveValue: { [weak scrollView] _ in
                scrollView?.contentInset.bottom = 0
                scrollView?.verticalScrollIndicatorInsets.bottom = 0
            })
            .store(in: &subscriptions)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        subscribe()
    }
    
    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        
        textView.textContainerInset = .init(
            top: 8,
            left: layoutMargins.left,
            bottom: 8,
            right: layoutMargins.right
        )
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        subscriptions.removeAll()
    }

}
