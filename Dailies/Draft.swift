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
        var tagIDs = Set<Tag.Identifier>()
        if case let .hasTags(selectedTagIDs) = ThoughtListFilter.shared.tagFilter {
            tagIDs = selectedTagIDs
        }
        ThoughtList.shared.modifyValue {
            
            $0[.init()] = .init(content: value, date: .init(), tagIDs: tagIDs)
        }
        value.removeAll()
    }
}
