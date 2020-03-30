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
@available(iOS 13.0, *)
class ComposerViewController: UIViewController {
    
    override var undoManager: UndoManager? { model.undoManager }
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var subscriptions = Set<AnyCancellable>()
    
    let model = ComposerModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.$draft
            .map { !$0.isEmpty }
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &subscriptions)
    }

    @IBAction func save(_ sender: Any) {
        
        model.publishDraft()
        undoManager?.setActionName("Publish Draft")
        
        presentingViewController?.dismiss(animated: true)
    }
    
}

@available(iOS 13.0, *)
extension ComposerViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        model.draft = textView.text
    }
    
}
