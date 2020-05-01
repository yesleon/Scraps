//
//  Scrap.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//


import Foundation

struct Scrap: Codable, Equatable, FileWrapperConvertible, Identifiable {
    var id: UUID
    var content: String
    var date: Date
    var tagIDs: Set<Tag.ID>
    var attachment: Attachment?
}

struct Attachment: Equatable, Hashable, Codable {
    enum Kind: String, Codable {
        case image, linkMetadata, drawing
    }
    var kind: Kind
    var content: Data
}

import UIKit
import LinkPresentation
import PencilKit

extension Attachment {
    
    func view() throws -> UIView {
        switch kind {
        case .image:
            let image = UIImage(data: content)
            return UIImageView(image: image)
        case .linkMetadata:
            let metadata = try NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: content)
            return LPLinkView(metadata: metadata!)
        case .drawing:
            let view = PKCanvasView()
            view.drawing = try PKDrawing(data: content)
            return view
        }
    }
    
}
