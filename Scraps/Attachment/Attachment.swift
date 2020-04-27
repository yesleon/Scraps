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
    struct Identifier: Codable, Hashable, FilenameConvertible {
        let url: URL
    }
    case image([CGFloat: UIImage]), linkMetadata(LPLinkMetadata), drawing(PKDrawing)
    
}

extension Attachment.Identifier {
    
    var filename: String {
        url.lastPathComponent
    }
    
    init?(_ filename: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "treehole"
        urlComponents.host = "attachments"
        urlComponents.path = filename
        guard let url = urlComponents.url else { return nil }
        self.url = url
    }
    
}

extension PKDrawing: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.dataRepresentation())
    }
}
