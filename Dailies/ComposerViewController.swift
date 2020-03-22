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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
    }
    
    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        
        
        textView.textContainerInset = .init(
            top: 8,
            left: view.layoutMargins.left,
            bottom: 8,
            right: view.layoutMargins.right
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Document.shared.draft = textView.text
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.text = Document.shared.draft ?? ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
}

extension ComposerViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            Document.shared.addThought(.init(content: textView.text, date: Date()))
            textView.text.removeAll()
            presentingViewController?.dismiss(animated: true)
            return false
        } else {
            return true
        }
    }
}
