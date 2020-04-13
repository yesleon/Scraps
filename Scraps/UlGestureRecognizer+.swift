//
//  UIGestureRecognizer+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/13.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

private class GestureRecognizerTarget<T: UIGestureRecognizer>: NSObject {
    internal init(action: @escaping (T) -> Void) {
        self.action = action
    }
    let action: (T) -> Void
    @objc func handleAction(sender: Any) {
        let sender = sender as! T
        action(sender)
    }
}

protocol BlockGestureRecognizer { }
extension BlockGestureRecognizer where Self: UIGestureRecognizer {
    init(handler: @escaping (Self) -> Void) {
        let target = GestureRecognizerTarget<Self>(action: handler)
        self.init(target: target, action: #selector(GestureRecognizerTarget<Self>.handleAction(sender:)))
        UIGestureRecognizer.targets.append(target)
    }
}

extension UIGestureRecognizer: BlockGestureRecognizer {
    
    static var targets = [Any]()
    
    
    
}
