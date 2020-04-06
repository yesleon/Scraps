//
//  PresentTagListSegue.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class PresentTagListSegue: UIStoryboardSegue {

    override func perform() {
        destination.popoverPresentationController?.delegate = self
        destination.preferredContentSize = .init(width: 240, height: 360)
        
        super.perform()
    }
}



extension PresentTagListSegue: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
}
