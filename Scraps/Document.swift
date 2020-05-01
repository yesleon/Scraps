//
//  Document.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

import LinkPresentation
import PencilKit
import AVFoundation


/// The Model. Holds data and publishes data changes. I/O to disk.
/// Converts between disk data structure and data structure in app.
class Document: UIDocument {
    
    enum Error: Swift.Error {
        case readingError(Any)
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe() {
        weak var undoManager = self.undoManager
        
        Model.shared.scrapsSubject
            .previousResult(initialResult: [])
            .sink(receiveValue: { oldValue in
                undoManager?.registerUndo(withTarget: Model.shared.scrapsSubject) {
                    $0.value = oldValue
                }
            })
            .store(in: &subscriptions)
        
        Model.shared.tagsSubject
            .previousResult(initialResult: [])
            .sink(receiveValue: { oldValue in
                undoManager?.registerUndo(withTarget: Model.shared.tagsSubject) {
                    $0.value = oldValue
                }
            })
            .store(in: &self.subscriptions)
    }
    
    func openOrCreateIfFileNotExists(completionHandler: ((Bool) -> Void)? = nil) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            open(completionHandler: completionHandler)
        } else {
            save(to: fileURL, for: .forCreating, completionHandler: completionHandler)
        }
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let rootFolder = contents as? FileWrapper else { throw Error.readingError(contents) }
        guard let folders = rootFolder.fileWrappers else { throw Error.readingError(contents) }
        guard let scrapsFolder = folders["Scraps"] else { throw Error.readingError(contents) }
        guard let tagsFolder = folders["Tags"] else { throw Error.readingError(contents) }
        
        
        
        Model.shared.scrapsSubject.value = try .init(fileWrapper: scrapsFolder)

        Model.shared.tagsSubject.value = try .init(fileWrapper: tagsFolder)
        
        undoManager.removeAllActions()
    }
    
    override func contents(forType typeName: String) throws -> Any {
        return FileWrapper(directoryWithFileWrappers: [
            "Scraps": try Model.shared.scrapsSubject.value.fileWrapperRepresentation(),
            "Tags": try Model.shared.tagsSubject.value.fileWrapperRepresentation(),
        ])
    }
    
    override func handleError(_ error: Swift.Error, userInteractionPermitted: Bool) {
        super.handleError(error, userInteractionPermitted: userInteractionPermitted)
        print(error)
    }
}


