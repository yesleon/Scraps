//
//  DraftViewController.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import PencilKit

/// Handles user input in `ComposerView`.
class DraftViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var draftView: DraftView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe() {
        subscriptions.removeAll()
        
        Draft.shared.$value
            .combineLatest(Draft.shared.$attachment)
            .map { !$0.isEmpty || $1 != nil }
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &subscriptions)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        draftView.textView.inputAccessoryView = {
            let toolbar = UIToolbar()
            toolbar.items = [
                .flexibleSpace(),
                .init(image: UIImage(systemName: "link"), style: .plain) { [weak self] _ in
                    guard let self = self else { return }
                    self.draftView.textView.resignFirstResponder()
                    self.present(.saveURLAlert(), animated: true)
                },
                .fixedSpace(width: 16),
                .init(image: UIImage(systemName: "pencil"), style: .plain) { [weak self] _ in
                    guard let self = self else { return }
                    self.draftView.textView.resignFirstResponder()
                    let vc = CanvasViewController()
                    vc.saveHandler = Draft.shared.saveDrawing
                    self.present(UINavigationController(rootViewController: vc), animated: true)
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
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        Draft.shared.saveImage(image, dimensions: [.maxDimension, .itemWidth])
    }
    
}
