//
//  Attachment.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/7.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

import UIKit
import LinkPresentation

struct Attachment {
    struct Identifier: Codable, Hashable {
        private let url: URL
        init(newAttachment: NewAttachment) {
            switch newAttachment {
            case .image(_):
                var components = URLComponents()
                components.scheme = "treehole"
                components.host = "assets"
                components.path = "/" + UUID().uuidString
                self.url = components.url!
            case .link(let url):
                self.url = url
            }
        }
    }
    enum LoadedContent {
        case image(Image), linkMetadata(LPLinkMetadata)
    }
    var loadedContent: LoadedContent?
}

struct Image {
    var value: [Int: UIImage]
}
