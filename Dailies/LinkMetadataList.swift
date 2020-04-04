//
//  LinkMetadataList.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/4/3.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import LinkPresentation
import Combine

class LinkMetadataList {
    static let shared = LinkMetadataList()
    private var value = [URL: LPLinkMetadata]()
    
    func metadataPublisher(for url: URL) -> AnyPublisher<LPLinkMetadata, Error> {
        if let metadata = value[url] {
            return Just(metadata).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Future<LPLinkMetadata, Error> { promise in
                LPMetadataProvider().startFetchingMetadata(for: url) { (metadata, error) in
                    promise(Result {
                        try error.map { throw $0 }
                        return metadata!
                    })
                    self.value[url] = metadata
                }
            }.eraseToAnyPublisher()
        }
    }
}
