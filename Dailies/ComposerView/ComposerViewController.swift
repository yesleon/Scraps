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
    @IBOutlet weak var textView: TextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let thought = Document.shared.editingThought {
            title = DateFormatter.localizedString(from: thought.date, dateStyle: .none, timeStyle: .medium)
        } else {
            Document.shared.editingThought = .init(content: "", date: .init())
        }
        
        Document.shared.$editingThought
            .compactMap { $0?.content }
            .map { !$0.isEmpty }
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &subscriptions)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    deinit {
        if Document.shared.thoughts.contains(where: { $0.date == Document.shared.editingThought?.date }) {
            Document.shared.editingThought = nil
        }
    }

    @IBAction func save(_ sender: Any) {
        
        Document.shared.thoughts.first(where: { $0.date == Document.shared.editingThought?.date }).map {
            _ = Document.shared.thoughts.remove($0)
        }
        Document.shared.editingThought.map { _ = Document.shared.thoughts.insert($0) }
        Document.shared.editingThought = nil
        undoManager?.setActionName("Publish Draft")
        
        presentingViewController?.dismiss(animated: true)
    }
    
}

extension ComposerViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if Document.shared.editingThought?.content != textView.text {
            Document.shared.editingThought?.content = textView.text
        }
    }
    
}
