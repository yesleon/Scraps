//
//  SceneDelegate.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/21.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        replaceWindow: do {
            guard let oldWindow = self.window else { break replaceWindow }
            guard let windowScene = oldWindow.windowScene else { break replaceWindow }
            let newWindow = Window(windowScene: windowScene)
            if let vc = oldWindow.rootViewController {
                oldWindow.rootViewController = nil
                newWindow.rootViewController = vc
            }
            newWindow.makeKeyAndVisible()
            
            self.window = newWindow
        }
    }
    
}

