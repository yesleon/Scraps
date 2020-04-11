//
//  UIViewController+.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/12.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


extension UIViewController {
    
    static func tagListViewController(thoughtIDs: Set<Thought.Identifier>, sourceView: UIView?, sourceRect: CGRect, barButtonItem: UIBarButtonItem?) -> UIViewController {
        let vc = TagListViewController()
        let view = TagListView()
        view.thoughtIDs = thoughtIDs
        view.delegate = vc
        vc.view = view
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController.map {
            $0.delegate = vc
            $0.sourceView = sourceView
            $0.sourceRect = sourceRect
            $0.barButtonItem = barButtonItem
        }
        vc.preferredContentSize = .init(width: 240, height: 360)
        return vc
    }
    
    static func tagNamingAlert(tagID: Tag.Identifier?) -> UIViewController {
        let vc = UIAlertController(title: NSLocalizedString("Name the Tag", comment: ""), message: nil, preferredStyle: .alert)
        var subscriptions = Set<AnyCancellable>()
        var text = ""
        let doneAction = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { _ in
            TagList.shared.modifyValue {
                $0.updateValue(.init(title: text), forKey: tagID ?? .init())
            }
            subscriptions.removeAll()
            vc.textFields?.forEach { $0.removeAllActions() }
        })
        doneAction.isEnabled = false
        vc.addTextField { textField in
            textField.addAction(for: .editingChanged) { textField, event in
                text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                doneAction.isEnabled = TagList.shared.isTitleValid(text)
                
            }
            if let tagID = tagID {
                TagList.shared.$value
                    .compactMap { $0[tagID]?.title }
                    .sink(receiveValue: {
                        textField.text = $0
                        textField.placeholder = $0
                    })
                    .store(in: &subscriptions)
            }
        }
        
        [doneAction, .init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)].forEach(vc.addAction(_:))
        return vc
    }
    
    static func saveURLAlert() -> UIViewController {
        let alertController = UIAlertController(title: "Insert Link", message: nil, preferredStyle: .alert)
        var linkURL: URL?
        let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
            linkURL.map(Draft.shared.saveURL)
        }
        doneAction.isEnabled = false
        
        alertController.addTextField {
            $0.addAction(for: .editingChanged) { textField, event in
                if let url = URL(string: textField.text ?? ""), UIApplication.shared.canOpenURL(url) {
                    doneAction.isEnabled = true
                    linkURL = url
                } else {
                    doneAction.isEnabled = false
                    linkURL = nil
                }
            }
        }
        
        alertController.addAction(doneAction)
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        return alertController
    }
    
    static func cameraPicker(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = delegate
        imagePicker.sourceType = .camera
        return imagePicker
    }
    
    static func photoLibraryPicker(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = delegate
        imagePicker.sourceType = .photoLibrary
        return imagePicker
    }
    
}
