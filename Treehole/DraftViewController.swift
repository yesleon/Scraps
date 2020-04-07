//
//  DraftViewController.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine


/// Handles user input in `ComposerView`.
@available(iOS 13.0, *)
class DraftViewController: UIViewController {
    
    @IBOutlet weak var draftView: DraftView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    lazy var cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(presentCamera(_:)))
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Draft.shared.$value
            .map { !$0.isEmpty }
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &subscriptions)
        
        draftView.toolbar.setItems([
            .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            cameraButton
        ], animated: false)
    }
    
    @objc func presentCamera(_ button: UIBarButtonItem) {
        
    }

    @IBAction func save(_ sender: Any) {
        Draft.shared.publish()
        
        presentingViewController?.dismiss(animated: true)
    }
    
}

@available(iOS 13.0, *)
extension DraftViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        Draft.shared.value = textView.text
    }
    
}
