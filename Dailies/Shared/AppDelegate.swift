//
//  AppDelegate.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/21.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import MainModel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Document.shared.open()
        return true
    }

}

