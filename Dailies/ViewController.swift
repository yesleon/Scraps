//
//  ViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/21.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet var textFieldConstraints: [NSLayoutConstraint]!
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup textFieldContainer tracking.
        
        let keyboardTrackerView = UIView()

        textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textField.inputAccessoryView = keyboardTrackerView
        
        var keyboardTracking: AnyCancellable?
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { _ in
                NSLayoutConstraint.deactivate(self.textFieldConstraints)
                self.textFieldContainer.translatesAutoresizingMaskIntoConstraints = true
                self.textField.translatesAutoresizingMaskIntoConstraints = true
                keyboardTracking = keyboardTrackerView.superview?.publisher(for: \.center)
                    .sink { _ in
                        var frame = self.view.convert(keyboardTrackerView.bounds, from: keyboardTrackerView)
                        frame.size.height = self.textFieldContainer.frame.height
                        frame.origin.y -= self.textFieldContainer.frame.height
                        self.textFieldContainer.frame = frame
                        
                } }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { _ in
                keyboardTracking?.cancel()
                NSLayoutConstraint.activate(self.textFieldConstraints)
                self.textFieldContainer.translatesAutoresizingMaskIntoConstraints = false
                self.textField.translatesAutoresizingMaskIntoConstraints = false
        }
            .store(in: &subscriptions)
        
    }
    
    
}
