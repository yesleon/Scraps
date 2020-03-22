//
//  ComposerViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class ComposerViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    weak var thoughtListViewController: ThoughtListViewController?
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .map(\.userInfo)
            .compactMap { $0?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .sink { [weak self] keyboardFrame in
                self?.textView.contentInset.bottom = keyboardFrame.height }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.textView.contentInset.bottom = 0 }
            .store(in: &subscriptions)
    }
    
    func saveThought() {
        thoughtListViewController?.addThought(textView.text)
        textView.text.removeAll()
        presentingViewController?.dismiss(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        thoughtListViewController?.saveDraft(textView.text)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        thoughtListViewController?.draft.map { self.textView.text = $0 }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
}

extension ComposerViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            saveThought()
            return false
        } else {
            return true
        }
    }
}
