//
//  TextListViewController.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class TextListViewController: UITableViewController {
    
    private var texts = [String]()
    private(set) var draft: String?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func addText(_ text: String) {
        texts.append(text)
        let indexPath = IndexPath(row: texts.count-1, section: 0)
        tableView.insertRows(at: [indexPath], with: .right)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func saveDraft(_ draft: String) {
        self.draft = draft
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = texts[indexPath.row]
        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "PresentComposerView":
            guard let nc = segue.destination as? UINavigationController, let composerVC = nc.viewControllers.first as? ComposerViewController else { break }
            composerVC.textListViewController = self
        default:
            break
        }
    }
    

}
