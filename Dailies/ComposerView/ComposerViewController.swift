//
//  ComposerViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine


/// Handles user input in `ComposerView`.
class ComposerViewController: UIViewController {
    
    override var undoManager: UndoManager? { Document.shared.undoManager }
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Document.shared.$draft
            .map { !$0.isEmpty }
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &subscriptions)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }

    @IBAction func save(_ sender: Any) {
        var thought = Thought(content: Document.shared.draft, date: .init())
        if case .hasTags(let tags) = Document.shared.tagFilter {
            thought.tags = tags
        }
        Document.shared.thoughts.insert(thought)
        Document.shared.draft.removeAll()
        undoManager?.setActionName("Publish Draft")
        
        presentingViewController?.dismiss(animated: true)
    }
    
}

extension ComposerViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if Document.shared.draft != textView.text {
            Document.shared.draft = textView.text
        }
    }
    
}
