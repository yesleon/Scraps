//
//  Attachment.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/7.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

import UIKit
import LinkPresentation
import PencilKit

enum Attachment: Equatable, Hashable {
    struct Identifier: Codable, Hashable {
        let url: URL
    }
    case image([CGFloat: UIImage]), linkMetadata(LPLinkMetadata), drawing(PKDrawing)
    
}

extension PKDrawing: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.dataRepresentation())
    }
}
