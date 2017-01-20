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

    struct RequestConstants {
        static let baseUrl = "https://api.github.com/"
        
        // MARK: Users method and params
        static let users = "users/"
        static let usersRepositories = "repos"

        // MARK: Repositories method and params
        static let repositories = "repos/"
        static let repositoriesCommits = "commits"
    }
    
    struct MappingConstants {
        struct CommonKeys {
            static let kId = "id"
            static let kDate = "date"
            static let kName = "name"
            static let kMessage = "message"
        }
        
        struct UserKeys {
            static let kAvatarUrl = "avatar_url"
        }
    }
    
    struct ApiConstants {
        static let notFoundAnswer = "Not Found"
    }
    
    public static let sharedController = GITHUBAPIController()

    public static let timeoutIntervalForRequest = 5.0 // 5 seconds
    
    private var sessionManager: SessionManager
    
    enum GITHUBError: Error {
        case RuntimeError(String)
    }
    
    private init() {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = GITHUBAPIController.timeoutIntervalForRequest
        
        sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    
    public func getAvatar(for userName: String, success: @escaping (UIImage)->Void,
                          failure: @escaping (Error)->Void) {
        self.getInfo(for: userName, success: { response in
            if let avatarURL = response.value(forKey: MappingConstants.UserKeys.kAvatarUrl) as? String {
                // get the image with one more request
                self.sessionManager.request(avatarURL).responseImage { responseImage in
                    if let image = responseImage.result.value {
                        success(image)
                    } else {
                        failure(GITHUBError.RuntimeError(NSLocalizedString("GitHubApi.Error.ImageLoadingFailed", comment: "")))
                    }
                }
            } else {
                failure(GITHUBError.RuntimeError(NSLocalizedString("GitHubApi.Error.AvatarUrlCouldNotBeParsed", comment: "")))
            }
        }, failure: { error in
            failure(error)
        })
    }
    
    public func getRepositoriesInfo(for userName: String, success: @escaping ([GITRepository])->Void,
                                    failure: @escaping (Error)->Void) {
        self.getRepositories(for: userName, success: { repositoriesResponse in
            var repositories = [GITRepository]()
            var errors = [Error]()
            let commitsGroup = DispatchGroup()

            for repositoryObject in repositoriesResponse.arrayValue {
                if let repositoryName = repositoryObject[MappingConstants.CommonKeys.kName].string {
                    commitsGroup.enter()
                    self.getCommits(for: userName, in: repositoryName, success: { commitsJSON in
                        let repository = GITRepository(name: repositoryName)
                        repository.mapCommitsInfo(commitsJSON: commitsJSON)
                        repositories.append(repository)
                        commitsGroup.leave()
                    }, failure: { error in
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
        }, failure: { error in
            failure(error)
        })
    }

    private func getInfo(for userName: String, success: @escaping (NSDictionary)->Void,
                         failure: @escaping (Error)->Void) {
        let requestURL = RequestConstants.baseUrl + RequestConstants.users + "\(userName)"
        self.sessionManager.request(requestURL).responseJSON {
            response in
            
            switch response.result {
            case .success(let json):
                if let response = json as? NSDictionary {
                    success(response)
                } else {
                    failure(GITHUBError.RuntimeError(NSLocalizedString("GitHubApi.Error.RepositoryInfoCouldNotBeParsed", comment: "")))
                }
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    private func getRepositories(for userName: String, success: @escaping (JSON)->Void,
                                 failure: @escaping (Error)->Void) {
        let requestURL = RequestConstants.baseUrl + RequestConstants.users + "\(userName)/" +
            RequestConstants.usersRepositories
        
        self.sessionManager.request(requestURL).responseJSON {
            response in
            
            switch response.result {
            case .success(let json):
                let swiftyJSON = JSON(json)
                if swiftyJSON.array == nil
                    && swiftyJSON[MappingConstants.CommonKeys.kMessage].string == ApiConstants.notFoundAnswer {
                    failure(GITHUBError.RuntimeError(NSLocalizedString("GitHubApi.Error.RepositoryIsNotFound", comment: "")))
                } else {
                    success(swiftyJSON)
                }
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    private func getCommits(for userName: String, in repositoryName: String,
                            success: @escaping (JSON)->Void, failure: @escaping (Error)->Void) {
        let requestURL = RequestConstants.baseUrl + RequestConstants.repositories +
            "\(userName)/\(repositoryName)/" + RequestConstants.repositoriesCommits
        self.sessionManager.request(requestURL).responseJSON {
            response in
            
            switch response.result {
            case .success(let json):
                let swiftyJSON = JSON(json)
                if swiftyJSON.array == nil
                    && swiftyJSON[MappingConstants.CommonKeys.kMessage].string == ApiConstants.notFoundAnswer {
                    failure(GITHUBError.RuntimeError(NSLocalizedString("GitHubApi.Error.CommitsAreNotFound", comment: "")))
                } else {
                    success(swiftyJSON)
                }
            case .failure(let error):
                failure(error)
            }
        }
    }

}
