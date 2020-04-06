//
//  NavigationController.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/3/27.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        
        navigationBar.layoutMargins = view.layoutMargins
    }

}
