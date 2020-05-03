//
//  UITableView+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/5/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


extension UITableView {
    
    var indexPathsForAllRows: AnySequence<IndexPath> {
        (0 ..< numberOfSections).lazy
            .flatMap({ section in
                (0 ..< self.numberOfRows(inSection: section))
                    .map({ row in IndexPath(row: row, section: section) })
            })
            .eraseToAnySequence()
    }
    
}
