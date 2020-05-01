//
//  AppDelegate.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/3/21.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


/// Holds the main document and sets global view appearances.
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    override var myUndoManager: UndoManager? { document?.undoManager }
    
    var document: UIDocument?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        self.document = {
            guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
            let document = Document(fileURL: documentURL.appendingPathComponent("database"))
            document.subscribe()
            document.openOrCreateIfFileNotExists()
            return document
        }()
        
        UIView.appearance().tintColor = .systemRed
        
        return true
    }

}
