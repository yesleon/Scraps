//
//  UIBarButtonItem+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/12.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

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
