//
//  DraftViewController.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

/// Handles user input in `ComposerView`.
class DraftViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var draftView: DraftView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.items = [
            .flexibleSpace(),
            .init(image: UIImage(systemName: "link"), style: .plain) { [weak self] _ in
                guard let self = self else { return }
                self.draftView.textView.resignFirstResponder()
                self.present(.saveURLAlert(), animated: true)
            },
            .fixedSpace(width: 16),
            .init(image: UIImage(systemName: "photo.on.rectangle"), style: .plain) { [weak self] _ in
                guard let self = self else { return }
                self.draftView.textView.resignFirstResponder()
                self.present(.photoLibraryPicker(delegate: self), animated: true)
            },
            .fixedSpace(width: 16),
            .init(barButtonSystemItem: .camera) { [weak self] _ in
                guard let self = self else { return }
                self.draftView.textView.resignFirstResponder()
                self.present(.cameraPicker(delegate: self), animated: true)
            }
        ]
        toolbar.sizeToFit()
        return toolbar
    }()
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe() {
        subscriptions.removeAll()
        
        Draft.shared.$value
            .combineLatest(Draft.shared.$attachment)
            .map { !$0.isEmpty || $1 != nil }
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &subscriptions)
        
        Draft.shared.$attachment
            .map { $0 != nil }
            .sink(receiveValue: { hasAttachment in
                self.toolbar.items?.forEach { $0.isEnabled = !hasAttachment }
            })
            .store(in: &subscriptions)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        draftView.textView.inputAccessoryView = toolbar
        
        subscribe()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        draftView.textView.becomeFirstResponder()
    }
    
    @IBAction func deleteAttachment(_ sender: UIButton) {
        Draft.shared.deleteAttachment()
    }

    @IBAction func save(_ sender: Any) {
        Draft.shared.publish()
        presentingViewController?.dismiss(animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        Draft.shared.value = textView.text
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.presentingViewController?.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        Draft.shared.saveImage(image)
    }
    
}
