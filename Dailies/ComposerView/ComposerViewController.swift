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
    
    override var undoManager: UndoManager? { Document.shared.undoManager }
    
    var subscriptions = Set<AnyCancellable>()
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Document.shared.$draft
            .map { $0 ?? "" }
            .map { !$0.isEmpty }
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &subscriptions)
    }

    @IBAction func save(_ sender: Any) {
        if let draft = Document.shared.draft {
            Document.shared.thoughts.insert(.init(content: draft, date: .init()))
            Document.shared.draft = nil
            undoManager?.setActionName("Publish Draft")
        }
        presentingViewController?.dismiss(animated: true)
    }
}

extension ComposerViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        Document.shared.draft = textView.text
    }
}
