//
//  TagListViewCell.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/5/4.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class TagListViewCell: UITableViewCell {
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe(tagID: Tag.ID, scrapIDs: Set<Scrap.ID>) {
        subscriptions.removeAll()
        Model.shared.tagsSubject.publisher(for: tagID)
            .combineLatest(Model.shared.scrapsSubject)
            .sink(receiveValue: { [weak self] tag, scraps in
                guard let self = self else { return }
                self.textLabel?.text = tag.title
                if scrapIDs.compactMap({ scraps[$0] }).allSatisfy({ $0.tagIDs.contains(tagID) }) {
                    self.accessoryType = .checkmark
                } else {
                    self.accessoryType = .none
                }
            })
            .store(in: &subscriptions)
    }

}
