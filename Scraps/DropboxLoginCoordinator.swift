//
//  DropboxLoginProcess.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/24.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class DropboxLoginProcess: NSObject {
    var completion: (() -> Void)?
    func login(completion: @escaping () -> Void) {
        self.completion = completion
        OAuthServerProxy.dropbox.authorize(withClientID: "pjwsk8p4dk374mp", redirectURI: "https://www.narrativesaw.com/auth")
    }
}
