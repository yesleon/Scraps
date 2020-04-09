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
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Draft.shared.$value
            .combineLatest(Draft.shared.$attachment)
            .map { !$0.isEmpty || $1 != nil }
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &subscriptions)
        
        let toolbar: UIToolbar = {
            let toolbar = UIToolbar()
            toolbar.items = [
                .flexibleSpace(),
                .init(image: UIImage(systemName: "link"), style: .plain, target: self, action: #selector(presentLinkAlert(_:))),
                .fixedSpace(width: 16),
                .init(image: UIImage(systemName: "photo.on.rectangle"), style: .plain, target: self, action: #selector(presentImagePicker(_:))),
                .fixedSpace(width: 16),
                .init(barButtonSystemItem: .camera, target: self, action: #selector(presentCamera(_:)))
            ]
            toolbar.sizeToFit()
            return toolbar
        }()
        
        draftView.inputAccessoryView = toolbar
        
        Draft.shared.$attachment
            .map { $0 != nil }
            .sink(receiveValue: { hasAttachment in
                toolbar.items?.forEach { $0.isEnabled = !hasAttachment }
            })
            .store(in: &subscriptions)
        
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
    
    @IBAction func deleteAttachment(_ sender: UIButton) {
        Draft.shared.deleteAttachment()
    }
    
    @objc func presentLinkAlert(_ button: UIBarButtonItem) {
        draftView.resignFirstResponder()
        let alertController = UIAlertController(title: "Insert Link", message: nil, preferredStyle: .alert)
        var textField: UITextField?
        var delegate: NSObject?
        let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
            guard let url = URL(string: textField?.text ?? "") else { return }
            Draft.shared.saveURL(url)
            delegate = nil
        }
        doneAction.isEnabled = false
        class TextFieldDelegate: NSObject {
            internal init(doneAction: UIAlertAction) {
                self.doneAction = doneAction
            }
            let doneAction: UIAlertAction
            
            @objc func textFieldDidChange(_ textField: UITextField) {
                if let url = URL(string: textField.text ?? ""), UIApplication.shared.canOpenURL(url) {
                    doneAction.isEnabled = true
                } else {
                    doneAction.isEnabled = false
                }
            }
        }
        delegate = TextFieldDelegate(doneAction: doneAction)
        
        alertController.addTextField {
            textField = $0
            $0.addTarget(delegate, action: #selector(TextFieldDelegate.textFieldDidChange(_:)), for: .editingChanged)
        }
        
        alertController.addAction(doneAction)
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    @objc func presentCamera(_ button: UIBarButtonItem) {
        draftView.resignFirstResponder()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }
    
    @objc func presentImagePicker(_ button: UIBarButtonItem) {
        draftView.resignFirstResponder()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
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
        Draft.shared.saveImage(image)
    }
}

extension UIBarButtonItem {
    static func flexibleSpace() -> UIBarButtonItem {
        .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    static func fixedSpace(width: CGFloat) -> UIBarButtonItem {
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = width
        return fixedSpace
    }
}
