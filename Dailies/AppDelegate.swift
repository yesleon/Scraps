//
//  AppDelegate.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/21.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var document = Document(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("data"))

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if FileManager.default.fileExists(atPath: document.fileURL.path) {
            document.open()
        } else {
            document.save(to: document.fileURL, for: .forCreating)
        }
        
        return true
    }

}

