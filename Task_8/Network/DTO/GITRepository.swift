//
//  GITRepository.swift
//  Task_8
//
//  Created by Kirill Asyamolov on 10/01/17.
//  Copyright © 2017 Kirill Asyamolov. All rights reserved.
//

import Foundation
import SwiftyJSON

class GITRepository {
   
    let kCommit = "commit"
    let kCommitter = "committer"
    let kName = "name"
    let kDate = "date"
    
    var name: String
    var lastCommitDate: String?
    var lastCommitAuthor: String?
    
    init(name: String) {
        self.name = name
    }
    
    public func mapCommitsInfo(commitsJSON: JSON) {
        lastCommitAuthor = commitsJSON[0][kCommit][kCommitter][kName].string
        lastCommitDate = commitsJSON[0][kCommit][kCommitter][kDate].string
    }
   
}
