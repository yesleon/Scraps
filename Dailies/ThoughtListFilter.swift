//
//  ThoughtListFilter.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

class ThoughtListFilter {
    static let shared = ThoughtListFilter()
    
    @Published var tagFilter = TagFilter.hasTags([])
}
