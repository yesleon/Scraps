//
//  Model.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/26.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class Model: NSObject {
    
    struct Section {
        var id: DateComponents
        var thoughts: [Thought]
    }
    
    var draft: String?

    var section = [Section]()
    
    func ingest(_ thoughts: Set<Thought>) {
        
    }
}
