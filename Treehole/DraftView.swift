//
//  DraftView.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine


@available(iOS 13.0, *)
class DraftView: UITextView {
    
    var subscriptions = Set<AnyCancellable>()
    lazy private(set) var toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: 0, height: 44))
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        inputAccessoryView = toolbar
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .map(\.userInfo)
            .compactMap { $0?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .sink(receiveValue: { [weak self] keyboardFrame in
                guard let self = self, let window = self.window, let superview = self.superview else { return }
                superview.layoutIfNeeded()
                let delta = window.bounds.maxY - superview.convert(self.frame, to: window).maxY
                self.contentInset.bottom = keyboardFrame.height - delta
            })
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.contentInset.bottom = 0 }
            .store(in: &subscriptions)
        
        Draft.shared.$value
            .filter { $0 != self.text }
            .assign(to: \.text, on: self)
            .store(in: &subscriptions)
        
        becomeFirstResponder()
    }
    
    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        
        textContainerInset = .init(
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
