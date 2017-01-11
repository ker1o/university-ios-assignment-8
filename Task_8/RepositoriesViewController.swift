//
//  RepositoriesViewController.swift
//  Task_8
//
//  Created by Kirill Asyamolov on 10/01/17.
//  Copyright © 2017 Kirill Asyamolov. All rights reserved.
//

import UIKit

class RepositoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let repositoriesCellIdentifier = "repositoriesCell"
    
    var repositories: [GITRepository]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repositories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: repositoriesCellIdentifier) as! RepositoryTableViewCell
        if let repository = repositories?[indexPath.row] {
            tableViewCell.nameLabel.text = repository.name
            if repository.lastCommitAuthor != nil {
                tableViewCell.authorLabel.text = repository.lastCommitAuthor
                tableViewCell.dateLabel.text = repository.lastCommitDate
            } else {
                tableViewCell.authorLabel.text = "There is no any commit yet"
                tableViewCell.dateLabel.text = ""
            }
        }
        
        return tableViewCell
    }

}
