//
//  SearchController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/29.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class SearchController: UISearchController {

    override var undoManager: UndoManager? { Document.shared.undoManager }
    
    override var canBecomeFirstResponder: Bool { !searchBar.isFirstResponder }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }

}

extension SearchController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        becomeFirstResponder()
    }
}
