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
    var isEnabled: Bool { get }
    var title: String? { get }
    var icon: UIImage? { get }
    func shouldInclude(_ scrap: Scrap) -> Bool
}

enum ScrapFilters {
    
    struct TextFilter: ScrapFilter {
        
        var icon: UIImage? {
            nil
        }
        
        func shouldInclude(_ scrap: Scrap) -> Bool {
            scrap.content.lowercased().contains(text.lowercased())
        }
        
        let isEnabled = true
        
        var title: String? { "\"\(text)\"" }
        
        let text: String
        
    }
    
    enum TagFilter: ScrapFilter {
        
        var icon: UIImage? {
            switch self {
            case .hasTags(_):
                return UIImage(systemName: "tag")
            case .noTags:
                return nil
            }
        }
        
        var title: String? {
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
        
        var icon: UIImage? {
            UIImage(systemName: "star")
        }
        
        var title: String? {
            NSLocalizedString("Today", comment: "")
        }
        
        let isEnabled = true
        
        func shouldInclude(_ scrap: Scrap) -> Bool {
            return Calendar.current.isDateInToday(scrap.date)
        }
        
    }
    
    struct KindFilter: ScrapFilter, Equatable {
        
        let kind: Attachment.Kind?
        
        func shouldInclude(_ scrap: Scrap) -> Bool {
            scrap.attachment?.kind == kind
        }
        
        let isEnabled = true
        
        var title: String? {
            switch kind {
            case .drawing:
                return NSLocalizedString("Drawings", comment: "")
            case .image:
                return NSLocalizedString("Images", comment: "")
            case .linkMetadata:
                return NSLocalizedString("Links", comment: "")
            case nil:
                return NSLocalizedString("Texts", comment: "")
            }
        }
        
        var icon: UIImage? {
            switch kind {
            case .drawing:
                return UIImage(systemName: "scribble")
            case .image:
                return UIImage(systemName: "photo.on.rectangle")
            case .linkMetadata:
                return UIImage(systemName: "link")
            case nil:
                return UIImage(systemName: "doc.text")
            }
        }
        
    }
    
    struct TodoFilter: ScrapFilter, Equatable {
        
        var icon: UIImage? {
            switch todo {
            case .anytime:
                return UIImage(systemName: "square")
            case .done:
                return UIImage(systemName: "checkmark.square")
            }
        }
        
        let todo: Todo
        
        func shouldInclude(_ scrap: Scrap) -> Bool {
            scrap.todo == todo
        }
        
        let isEnabled = true
        
        var title: String? {
            switch todo {
            case .anytime:
                return NSLocalizedString("Todo", comment: "")
            case .done:
                return NSLocalizedString("Finished Todo", comment: "")
            }
        }
        
    }
    
}

extension Array: ScrapFilter where Element == ScrapFilter {
    
    var icon: UIImage? {
        nil
    }
    
    var title: String? {
        let text = compactMap(\.title).joined(separator: ", ")
        return text.isEmpty ? nil : text
    }
    
    var isEnabled: Bool {
        contains(where: { $0.isEnabled })
    }
    
    func shouldInclude(_ scrap: Scrap) -> Bool {
        !contains(where: { !$0.shouldInclude(scrap) })
    }
    
}
