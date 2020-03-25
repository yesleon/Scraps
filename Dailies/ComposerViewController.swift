//
//  ComposerViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class ComposerViewController: UIViewController {

    @IBAction func save(_ sender: Any) {
//        Document.shared.publishDraft()
        presentingViewController?.dismiss(animated: true)
    }
}
