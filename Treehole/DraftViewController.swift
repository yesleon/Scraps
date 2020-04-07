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
    @IBOutlet weak var scrollView: UIScrollView!
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
        
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .map(\.userInfo)
            .compactMap { $0?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .sink(receiveValue: { [weak scrollView] keyboardFrame in
                guard let scrollView = scrollView, let window = scrollView.window, let superview = scrollView.superview else { return }
                superview.layoutIfNeeded()
                let delta = window.bounds.maxY - superview.convert(scrollView.frame, to: window).maxY
                scrollView.contentInset.bottom = keyboardFrame.height - delta
                scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height - delta
            })
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink(receiveValue: { [weak scrollView] _ in
                scrollView?.contentInset.bottom = 0
                scrollView?.verticalScrollIndicatorInsets.bottom = 0
            })
            .store(in: &subscriptions)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        draftView.becomeFirstResponder()
    }
    
    @objc func presentCamera(_ button: UIBarButtonItem) {
        draftView.resignFirstResponder()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
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

extension DraftViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.presentingViewController?.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        Draft.shared.attachment = .image(image)
    }
}
