//
//  ComposerModel.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import MainModel

@available(iOS 13.0, *)
class ComposerModel {
    
    static let shared = ComposerModel()
    var undoManager: UndoManager { Document.shared.undoManager }
    
    /// Just a place for storing draft.
    @Published var draft = ""
    
    func publishDraft() {
        var thought = Thought(content: ComposerModel.shared.draft, date: .init())
        if case .hasTags(let tags) = Document.shared.tagFilter {
            thought.tags = tags
        }
        Document.shared.thoughts.insert(thought)
        draft.removeAll()
    }
}
