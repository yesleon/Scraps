//
//  ThoughtListViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class ThoughtListViewController: UITableViewController {
    
    
    
    var document = Document(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("data"))
    
    var subscriptions = Set<AnyCancellable>()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = document
        
        document.publisher.sink { [weak tableView] in
            switch $0 {
            case .newIndexPath(let indexPath):
                tableView?.insertRows(at: [indexPath], with: .fade)
            case .newSection(let section):
                tableView?.insertSections([section], with: .fade)
            } }
            .store(in: &subscriptions)
        
        if FileManager.default.fileExists(atPath: document.fileURL.path) {
        
            document.open { _ in
                self.tableView.reloadData()
            }
        } else {
            document.save(to: document.fileURL, for: .forCreating) { _ in
                self.document.open()
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "PresentComposerView":
            guard let nc = segue.destination as? UINavigationController, let composerVC = nc.viewControllers.first as? ComposerViewController else { break }
            composerVC.document = document
        default:
            break
        }
    }
    

}
