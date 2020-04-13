//
//  ScrapFilters.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/13.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

protocol ScrapFilter {
    func shouldInclude(_ thought: Scrap) -> Bool
    var isEnabled: Bool { get }
    var stringRepresentation: String? { get }
}

enum ScrapFilters {
    enum TagFilter: ScrapFilter {
        var stringRepresentation: String? {
            switch self {
            case .hasTags(let tagIDs):
                if !tagIDs.isEmpty {
                    return tagIDs.lazy
                        .compactMap { TagList.shared.value[$0] }
                        .map(\.title)
                        .map({ "#" + $0 })
                        .joined(separator: ", ")
                } else {
                    return nil
                }
            case .noTags:
                return NSLocalizedString("No Tags", comment: "")
            }
        }
        
        var isEnabled: Bool {
            switch self {
            case .hasTags(let tagIDs):
                return !tagIDs.isEmpty
            case .noTags:
                return true
            }
        }
        
        case noTags, hasTags(Set<Tag.Identifier>)
        func shouldInclude(_ thought: Scrap) -> Bool {
            switch self {
            case .hasTags(let tagIDs):
                return tagIDs.isEmpty || thought.tagIDs.isSuperset(of: tagIDs)
            case .noTags:
                return thought.tagIDs.isEmpty
            }
        }
    }

    struct TodayFilter: ScrapFilter {
        var stringRepresentation: String? {
            NSLocalizedString("Today", comment: "")
        }
        
        let isEnabled = true
        func shouldInclude(_ thought: Scrap) -> Bool {
            return Calendar.current.isDateInToday(thought.date)
        }
    }
}

extension Array: ScrapFilter where Element == ScrapFilter {
    var stringRepresentation: String? {
        let text = compactMap(\.stringRepresentation).joined(separator: ", ")
        return text.isEmpty ? nil : text
    }
    
    var isEnabled: Bool {
        contains(where: { $0.isEnabled })
    }
    
    func shouldInclude(_ thought: Scrap) -> Bool {
        !contains(where: { !$0.shouldInclude(thought) })
    }
}
