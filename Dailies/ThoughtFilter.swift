//
//  ThoughtFilter.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

class ThoughtFilter {
    static let shared = ThoughtFilter()
    
    @Published private(set) var value: [ThoughtFiltering] = [
        TagFilter.hasTags([])
    ]
    
    func modifyValue<T: ThoughtFiltering>(ofType type: T.Type, handler: (inout T?) -> Void) {
        var value = self.value
        let index = value.firstIndex(where: { $0 is T })
        if let index = index, let filter = value[index] as? T {
            var filter: T? = filter
            handler(&filter)
            if let filter = filter {
                value[index] = filter
            } else {
                value.remove(at: index)
            }
        } else {
            var filter: T?
            handler(&filter)
            if let filter = filter {
                value.append(filter)
            }
        }
        self.value = value
    }
    
//    @Published var tagFilter = TagFilter.hasTags([])
//    @Published var todayFilter = TodayFilter(isEnabled: false)
}

protocol ThoughtFiltering {
    func shouldInclude(_ thought: Thought) -> Bool
    var isEnabled: Bool { get }
    var stringRepresentation: String? { get }
}

enum TagFilter: ThoughtFiltering {
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
    func shouldInclude(_ thought: Thought) -> Bool {
        switch self {
        case .hasTags(let tagIDs):
            return tagIDs.isEmpty || thought.tagIDs.isSuperset(of: tagIDs)
        case .noTags:
            return thought.tagIDs.isEmpty
        }
    }
}

struct TodayFilter: ThoughtFiltering {
    var stringRepresentation: String? {
        NSLocalizedString("Today", comment: "")
    }
    
    let isEnabled = true
    func shouldInclude(_ thought: Thought) -> Bool {
        return Calendar.current.isDateInToday(thought.date)
    }
}

extension Array: ThoughtFiltering where Element == ThoughtFiltering {
    var stringRepresentation: String? {
        let text = compactMap(\.stringRepresentation).joined(separator: ", ")
        return text.isEmpty ? nil : text
    }
    
    var isEnabled: Bool {
        contains(where: { $0.isEnabled })
    }
    
    func shouldInclude(_ thought: Thought) -> Bool {
        !contains(where: { !$0.shouldInclude(thought) })
    }
}

extension Array {
    
    func firstElement<T>(ofType: T.Type) -> T? {
        return first(where: { $0 is T }) as? T
    }
    
}
