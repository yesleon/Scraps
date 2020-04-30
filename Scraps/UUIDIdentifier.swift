//
//  UUIDIdentifier.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/28.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation


struct UUIDIdentifier: Codable, Hashable {
    
    let uuid: UUID
    
    init() {
        uuid = UUID()
    }
    
}

extension UUIDIdentifier: FilenameConvertible {
    
    var filename: String {
        uuid.uuidString
    }
    
    init?(_ filename: String) {
        guard let uuid = UUID(uuidString: filename) else { return nil }
        self.uuid = uuid
    }
    
}
