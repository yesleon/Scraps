//
//  ScrapFilters.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/13.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import UIKit

protocol ScrapFilter {
    func shouldInclude(_ scrap: Scrap) -> Bool
    var isEnabled: Bool { get }
    var stringRepresentation: String? { get }
}

enum ScrapFilters {
    
    struct TextFilter: ScrapFilter {
        func shouldInclude(_ scrap: Scrap) -> Bool {
            scrap.content.lowercased().contains(text.lowercased())
        }
        
        let isEnabled = true
        
        var stringRepresentation: String? { "\"\(text)\"" }
        
        var text: String
    }
    
    enum TagFilter: ScrapFilter {
        
        var stringRepresentation: String? {
            switch self {
            case .hasTags(let tagIDs):
                if !tagIDs.isEmpty {
                    return tagIDs.lazy
                        .compactMap { Model.shared.tagsSubject.value[$0] }
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
        
        case noTags, hasTags(Set<Tag.ID>)
        func shouldInclude(_ scrap: Scrap) -> Bool {
            switch self {
            case .hasTags(let tagIDs):
                return tagIDs.isEmpty || scrap.tagIDs.isSuperset(of: tagIDs)
            case .noTags:
                return scrap.tagIDs.isEmpty
            }
        }
        
    }

    struct TodayFilter: ScrapFilter {
        var stringRepresentation: String? {
            NSLocalizedString("Today", comment: "")
        }
        
        let isEnabled = true
        func shouldInclude(_ scrap: Scrap) -> Bool {
            return Calendar.current.isDateInToday(scrap.date)
        }
    }
    
    struct KindFilter: ScrapFilter, Equatable {
        
        var kind: Attachment.Kind?
        
        func shouldInclude(_ scrap: Scrap) -> Bool {
            scrap.attachment?.kind == kind
        }
        
        let isEnabled = true
        
        var stringRepresentation: String? {
            switch kind {
            case .drawing:
                return "Drawings"
            case .image:
                return "Images"
            case .linkMetadata:
                return "Links"
            case nil:
                return "Texts"
            }
        }
        
        func imageRepresentation(selected: Bool) -> UIImage? {
            switch kind {
            case .drawing:
                return UIImage(systemName: "scribble")
            case .image:
                return UIImage(systemName: selected ? "photo.fill.on.rectangle.fill" : "photo.on.rectangle")
            case .linkMetadata:
                return UIImage(systemName: "link")
            case nil:
                return UIImage(systemName: selected ? "doc.text.fill" : "doc.text")
            }
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
    
    func shouldInclude(_ scrap: Scrap) -> Bool {
        !contains(where: { !$0.shouldInclude(scrap) })
    }
}
