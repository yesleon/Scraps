//
//  UUID+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

extension UUID: FilenameConvertible {
    
    init?(_ filename: String) {
        self.init(uuidString: filename)
    }
    
    var filename: String {
        uuidString
    }
    
}
