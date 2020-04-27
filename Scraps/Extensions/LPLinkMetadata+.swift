//
//  LPLinkMetadata+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/9.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import LinkPresentation

extension LPLinkMetadata {
    
    convenience init(originalURL: URL) {
        self.init()
        self.originalURL = originalURL
    }
    
}
