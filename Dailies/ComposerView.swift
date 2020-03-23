//
//  ComposerView.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class ComposerView: UITextView {
    
    var subscriptions = Set<AnyCancellable>()
    
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
    }

}
