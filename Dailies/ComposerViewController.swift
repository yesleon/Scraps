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

    @IBAction func save(_ sender: Any) {
        if let draft = Document.shared.draft {
            Document.shared.thoughtsAsSet.insert(.init(content: draft, date: .init()))
            Document.shared.draft = nil
        }
        presentingViewController?.dismiss(animated: true)
    }
}

extension ComposerViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        Document.shared.draft = textView.text
    }
}
