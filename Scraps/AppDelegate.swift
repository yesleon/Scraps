//
//  AppDelegate.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/3/21.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    override var myUndoManager: UndoManager? { document.undoManager }
    
    lazy var document = Document(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("database"))

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        document.subscribe()
        document.openOrCreateIfFileNotExists()
        
        UIView.appearance().tintColor = .systemRed
//        UITableViewHeaderFooterView.appearance().tintColor = nil
        
        return true
    }

}
