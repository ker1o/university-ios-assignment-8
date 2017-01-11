//
//  GITHUBAPIController.swift
//  Task_8
//
//  Created by Kirill Asyamolov on 09/01/17.
//  Copyright © 2017 Kirill Asyamolov. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON


class GITHUBAPIController {

    public static let sharedController = GITHUBAPIController()

    public static let timeoutIntervalForRequest = 5.0 // 5 seconds
    
    private let baseAPIURL = "https://api.github.com/"
    
    private var sessionManager: SessionManager
    
    enum GITHUBError: Error {
        case RuntimeError(String)
    }
    
    private init() {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = GITHUBAPIController.timeoutIntervalForRequest
        
        sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    
    public func getAvatar(for userName: String, success: @escaping (UIImage)->Void, failure: @escaping (Error)->Void) {
        self.getInfo(for: userName,
                success: {response in
                    if let avatarURL = response.value(forKey: "avatar_url") as? String {
                        //get the image with one more request
                        self.sessionManager.request(avatarURL).responseImage { responseImage in
                            if let image = responseImage.result.value {
                                success(image)
                            } else {
                                failure(GITHUBError.RuntimeError("Image loading failed."))
                            }
                        }
                    } else {
                        failure(GITHUBError.RuntimeError("Avatar URL could not be parsed."))
                    }
                },
                failure: {error in
                    failure(error)
                })
    }
    
    public func getRepositoriesInfo(for userName: String, success: @escaping ([GITRepository])->Void, failure: @escaping (Error)->Void) {
        self.getRepositories(for: userName,
                             success: { repositoriesResponse in
                                var repositories = [GITRepository]()
                                var errors = [Error]()
                                let commitsGroup = DispatchGroup()

                                for repositoryObject in repositoriesResponse.arrayValue {
                                    if let repositoryName = repositoryObject["name"].string {
                                        commitsGroup.enter()
                                        self.getCommits(for: userName,
                                                        in: repositoryName,
                                                        success: {commitsJSON in
                                                            let lastCommitAuthor = commitsJSON[0]["commit"]["committer"]["name"].string
                                                            let lastCommitDate = commitsJSON[0]["commit"]["committer"]["date"].string
                                                            let repository = GITRepository(name: repositoryName, lastCommitDate: lastCommitDate, lastCommitAuthor: lastCommitAuthor)
                                                            repositories.append(repository)
                                                            commitsGroup.leave()
                                                        },
                                                        failure: {error in
                                                            errors.append(error)
                                                            commitsGroup.leave()
                                                        })
                                    }
                                }
                                
                                commitsGroup.notify(queue: DispatchQueue.main) {
                                    if errors.count > 0 && repositories.count == 0 {
                                        for error in errors {
                                            failure(error)
                                        }
                                    } else {
                                        success(repositories)
                                    }
                                }
                             },
                             failure: {error in
                                failure(error)
                             })
    }

    private func getInfo(for userName: String, success: @escaping (NSDictionary)->Void, failure: @escaping (Error)->Void) {
        let requestURL = baseAPIURL + "users/\(userName)"
        self.sessionManager.request(requestURL).responseJSON {
            response in
            
            switch response.result {
            case .success(let json):
                if let response = json as? NSDictionary {
                    success(response)
                } else {
                    failure(GITHUBError.RuntimeError("Repository info couldn't be parsed"))
                }
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    private func getRepositories(for userName: String, success: @escaping (JSON)->Void, failure: @escaping (Error)->Void) {
        let requestURL = baseAPIURL + "users/\(userName)/repos"
        
        self.sessionManager.request(requestURL).responseJSON {
            response in
            
            switch response.result {
            case .success(let json):
                let swiftyJSON = JSON(json)
                if swiftyJSON.array == nil && swiftyJSON["message"].string == "Not Found" {
                    failure(GITHUBError.RuntimeError("Repository is not found!"))
                } else {
                    success(swiftyJSON)
                }
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    private func getCommits(for userName: String, in repositoryName: String, success: @escaping (JSON)->Void, failure: @escaping (Error)->Void) {
        let requestURL = baseAPIURL + "repos/\(userName)/\(repositoryName)/commits"
        self.sessionManager.request(requestURL).responseJSON {
            response in
            
            switch response.result {
            case .success(let json):
                let swiftyJSON = JSON(json)
                if swiftyJSON.array == nil && swiftyJSON["message"].string == "Not Found" {
                    failure(GITHUBError.RuntimeError("Commits are not found!"))
                } else {
                    success(swiftyJSON)
                }
            case .failure(let error):
                failure(error)
            }
        }
    }

}
