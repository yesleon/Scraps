//
//  ScrapFilterList.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

//class ScrapFilterList: Model<[ScrapFilter]> {
//    
//    static let shared = ScrapFilterList([ScrapFilters.TagFilter.hasTags([])])
//    
//    func modifyValue<T: ScrapFilter>(ofType type: T.Type, handler: (inout T?) -> Void) {
//        modifyValue { value in
//            let index = value.firstIndex(where: { $0 is T })
//            if let index = index, let filter = value[index] as? T {
//                var filter: T? = filter
//                handler(&filter)
//                if let filter = filter {
//                    value[index] = filter
//                } else {
//                    value.remove(at: index)
//                }
//            } else {
//                var filter: T?
//                handler(&filter)
//                if let filter = filter {
//                    value.append(filter)
//                }
//            }
//        }
//    }
//    
//}


