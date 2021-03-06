//
//  UIViewController+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/12.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


extension UIViewController {
    
    static func tagListViewController(scrapIDs: Set<Scrap.ID>, sourceView: UIView?, sourceRect: CGRect, barButtonItem: UIBarButtonItem?) -> UIViewController {
        let vc = TagListViewController()
        let view = TagListView()
        view.scrapIDs = scrapIDs
        view.delegate = vc
        vc.view = view
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController.map {
            $0.delegate = vc
            $0.sourceView = sourceView
            $0.sourceRect = sourceRect
            $0.barButtonItem = barButtonItem
            $0.passthroughViews = nil
        }
        vc.preferredContentSize = .init(width: 240, height: 360)
        return vc
    }
    
    static func tagNamingAlert(tagID: Tag.ID?, doneCompletion: ((Tag.ID) -> Void)? = nil) -> UIViewController {
        let vc = UIAlertController(title: NSLocalizedString("Name the Tag", comment: ""), message: nil, preferredStyle: .alert)
        var subscriptions = Set<AnyCancellable>()
        var text = ""
        let doneAction = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { _ in
            let tagID = tagID ?? .init()
            Model.shared.tagsSubject.value[tagID, default: Tag(id: tagID, title: "")].title = text
            subscriptions.removeAll()
            vc.textFields?.forEach { $0.removeAllActions() }
            doneCompletion?(tagID)
        })
        doneAction.isEnabled = false
        vc.addTextField { textField in
            textField.addAction(for: .editingChanged) { textField in
                text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                doneAction.isEnabled = Model.shared.tagsSubject.isTitleValid(text)
                
            }
            if let tagID = tagID {
                Model.shared.tagsSubject
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
        let alertController = UIAlertController(title: NSLocalizedString("Insert Link", comment: ""), message: nil, preferredStyle: .alert)
        var linkURL: URL?
        let doneAction = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default) { _ in
            linkURL.map(Draft.shared.saveURL)
        }
        doneAction.isEnabled = false
        
        alertController.addTextField {
            $0.addAction(for: .editingChanged) { textField in
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
        alertController.addAction(.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
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
