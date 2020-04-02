//
//  Draft.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

class Draft {
    static let shared = Draft()
    
    @Published var value = ""
    
    func publish() {
        ThoughtList.shared.modifyValue {
            $0.insert(.init(content: value, date: .init()))
        }
        value.removeAll()
    }
}
