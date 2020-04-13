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
    
    struct AttachmentTypeFilter: ScrapFilter {
        func shouldInclude(_ scrap: Scrap) -> Bool {
            switch attachment {
            case .drawing(_):
                if case .drawing(_) = scrap.attachmentID.flatMap({ AttachmentList.shared.value[$0] }) {
                    return true
                } else {
                    return false
                }
            case .image(_):
                if case .image(_) = scrap.attachmentID.flatMap({ AttachmentList.shared.value[$0] }) {
                    return true
                } else {
                    return false
                }
            case .linkMetadata(_):
                if case .linkMetadata(_) = scrap.attachmentID.flatMap({ AttachmentList.shared.value[$0] }) {
                    return true
                } else {
                    return false
                }
            case nil:
                return scrap.attachmentID == nil
            }
        }
        
        let isEnabled = true
        
        var stringRepresentation: String? {
            switch attachment {
            case .drawing(_):
                return "Drawings"
            case .image(_):
                return "Images"
            case .linkMetadata(_):
                return "Links"
            case nil:
                return "Texts"
            }
        }
        
        func imageRepresentation(selected: Bool) -> UIImage? {
            switch attachment {
            case .drawing(_):
                return UIImage(systemName: "scribble")
            case .image(_):
                return UIImage(systemName: selected ? "photo.fill.on.rectangle.fill" : "photo.on.rectangle")
            case .linkMetadata(_):
                return UIImage(systemName: "link")
            case nil:
                return UIImage(systemName: selected ? "doc.text.fill" : "doc.text")
            }
        }
        
        var attachment: Attachment?
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
