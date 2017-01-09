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

class GITHUBAPIController: NSObject {

    public static let sharedController = GITHUBAPIController()

    private let baseAPIURL = "https://api.github.com/"
    
    enum GITHUBError: Error {
        case RuntimeError(String)
    }
    
    
    private override init() {
        
    }
    
    public func getInfo(for userName: String, success: @escaping (NSDictionary)->Void, failure: @escaping (Error)->Void) {
        let requestURL = baseAPIURL + "users/\(userName)"
        Alamofire.request(requestURL).responseJSON{
            response in
            
            switch response.result {
            case .success(let json):
                if let response = json as? NSDictionary {
                    success(response)
                } else {
                    failure(GITHUBError.RuntimeError("JSON could not be parsed."))
                }
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    public func getAvatar(for userName: String, success: @escaping (UIImage)->Void, failure: @escaping (Error)->Void) {
        getInfo(for: userName,
                success: {response in
                    if let avatarURL = response.value(forKey: "avatar_url") as? String {
                        //get the image with one more request
                        Alamofire.request(avatarURL).responseImage { responseImage in
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
    
    


}
