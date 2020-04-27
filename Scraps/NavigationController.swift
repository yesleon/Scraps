//
//  NavigationController.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/3/27.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


/// A navigation controller whose sets its navigation bar margins to its view margins.
class NavigationController: UINavigationController {

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        
        navigationBar.layoutMargins = view.layoutMargins
    }

}
