//
//  UIResponder+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/26.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

extension UIResponder {
    
    @objc var myUndoManager: UndoManager? {
        next?.myUndoManager
    }
    
    func updateHeight(for cell: UITableViewCell) {
        if let self = self as? UITableView, self.visibleCells.contains(cell) {
            self.beginUpdates()
            self.endUpdates()
        } else {
            next?.updateHeight(for: cell)
        }
    }
    
    func updateLayout() {
        if let self = self as? UITableViewCell {
            updateHeight(for: self)
        } else {
            next?.updateLayout()
        }
    }
    
}
