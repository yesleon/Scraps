//
//  TextView.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class TextView: UITextView {
    
    var subscriptions = Set<AnyCancellable>()
    
    override var text: String! {
        didSet {
            if Document.shared.draft != text {
                Document.shared.draft = text
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .map(\.userInfo)
            .compactMap { $0?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .sink { [weak self] keyboardFrame in
                guard let self = self, let window = self.window else { return }
                let delta = window.bounds.maxY - self.convert(self.bounds, to: window).maxY
                self.contentInset.bottom = keyboardFrame.height - delta }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.contentInset.bottom = 0 }
            .store(in: &subscriptions)
        
        Document.shared.$draft
            .filter { $0 != self.text }
            .assign(to: \.text, on: self)
            .store(in: &subscriptions)
        
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
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

}
