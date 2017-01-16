//
//  GITRepository.swift
//  Task_8
//
//  Created by Kirill Asyamolov on 10/01/17.
//  Copyright © 2017 Kirill Asyamolov. All rights reserved.
//

import Foundation

class GITRepository {
    var name: String
    var lastCommitDate: String?
    var lastCommitAuthor: String?
    
    init(name: String, lastCommitDate: String?, lastCommitAuthor: String?) {
        self.name = name
        self.lastCommitDate = lastCommitDate
        self.lastCommitAuthor = lastCommitAuthor
    }
    
    
}
