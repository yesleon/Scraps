//
//  UIBarButtonItem+.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/12.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class BarButtonItemTarget: NSObject {
    static let shared = BarButtonItemTarget()
    var actions = [ObjectIdentifier: (UIBarButtonItem) -> Void]()
    @objc func handleAction(sender: UIBarButtonItem) {
        actions[ObjectIdentifier(sender)]?(sender)
    }
}

extension UIBarButtonItem {
    
    convenience init(barButtonSystemItem: SystemItem, handler: @escaping (UIBarButtonItem) -> Void) {
        self.init(barButtonSystemItem: barButtonSystemItem, target: BarButtonItemTarget.shared, action: #selector(BarButtonItemTarget.handleAction(sender:)))
        BarButtonItemTarget.shared.actions[ObjectIdentifier(self)] = handler
    }
    convenience init(image: UIImage?, style: UIBarButtonItem.Style, handler: @escaping (UIBarButtonItem) -> Void) {
        self.init(image: image, style: style, target: BarButtonItemTarget.shared, action: #selector(BarButtonItemTarget.handleAction(sender:)))
        BarButtonItemTarget.shared.actions[ObjectIdentifier(self)] = handler
    }
    static func flexibleSpace() -> UIBarButtonItem {
        .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    static func fixedSpace(width: CGFloat) -> UIBarButtonItem {
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = width
        return fixedSpace
    }
}
