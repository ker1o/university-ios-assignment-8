//
//  RepositoriesViewController.swift
//  Task_8
//
//  Created by Kirill Asyamolov on 10/01/17.
//  Copyright © 2017 Kirill Asyamolov. All rights reserved.
//

import UIKit

class RepositoriesViewController: UIViewController {
    
    var repositories: [GITRepository]?
}

extension RepositoriesViewController: UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.reuseIdentifier,
                                                          for: indexPath) as! RepositoryTableViewCell
        if let repository = repositories?[indexPath.row] {
            tableViewCell.nameLabel.text = repository.name
            if repository.lastCommitAuthor != nil {
                tableViewCell.authorLabel.text = repository.lastCommitAuthor
                tableViewCell.dateLabel.text = repository.lastCommitDate
            } else {
                tableViewCell.authorLabel.text = NSLocalizedString("Repository.NoCommits", comment: "")
                tableViewCell.dateLabel.text = ""
            }
        }
        
        return tableViewCell
    }
    
}
