//
//  UIResponder+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/26.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

extension UIResponder {
    
    @objc var myUndoManager: UndoManager? {
        next?.myUndoManager
    }
    
    func insertIntoViewControllerHierarchy(_ vc: UIViewController) {
        if let self = self as? UIViewController, self !== vc {
            self.addChild(vc)
            vc.didMove(toParent: self)
        } else {
            next?.insertIntoViewControllerHierarchy(vc)
        }
    }
    
}
