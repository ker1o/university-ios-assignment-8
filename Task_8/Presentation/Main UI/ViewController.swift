//
//  ViewController.swift
//  Task_8
//
//  Created by Kirill Asyamolov on 09/01/17.
//  Copyright © 2017 Kirill Asyamolov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {


    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    private var grayView: UIView!
    private var indicator: UIActivityIndicatorView!
    
    private var controller: GITHUBAPIController = GITHUBAPIController.sharedController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        showImage()
        return true
    }
    
    @IBAction func findButtonClickHandler(_ sender: AnyObject) {
        showImage()
    }
    
    func showImage() {
        textField.resignFirstResponder()
        
        if let userName = self.textField.text {
            showLoadingScreen()
/*
            controller.getAvatar(for: userName,
                                 success: {image in
                                    self.hideLoadingScreen()
                                    self.imageView.image = image
                                 },
                                 failure: {error in
                                    self.hideLoadingScreen()
                                    self.showErrorPopup(error: error)
                                 })
*/
            
            controller.getRepositoriesInfo(for: userName,
                                           success: {repositories in
                                                self.hideLoadingScreen()
                                                self.showRepositoriesScreen(userName: userName, repositories: repositories)
                                            },
                                           failure: {error in
                                                self.hideLoadingScreen()
                                                self.showErrorPopup(error: error)
                                            })
        } else {
            print("Please enter the nickname.")
        }
    }
    
    func showRepositoriesScreen(userName: String, repositories: [GITRepository]) {
        let repositoriesViewController = UIStoryboard.main.viewController(type: RepositoriesViewController.self)
        repositoriesViewController.title = userName
        repositoriesViewController.repositories = repositories
        self.navigationController?.pushViewController(repositoriesViewController, animated: true)
    }
    
    func showErrorPopup(error: Error) {
        var message: String
        switch error {
        case GITHUBAPIController.GITHUBError.RuntimeError(let errorMessage):
            message = errorMessage
        default:
            message = error.localizedDescription
        }
        let errorPopup = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okButtonAction = UIAlertAction(title: "OK", style: .default) {
            action in
            errorPopup.dismiss(animated: true, completion: nil)
        }
        errorPopup.addAction(okButtonAction)
        self.present(errorPopup, animated: true, completion: nil)
    }
    
    func showLoadingScreen() {
        if grayView == nil {
            grayView = UIView(frame: self.view.bounds)
            grayView.backgroundColor = UIColor(white: CGFloat(0), alpha: CGFloat(0.5))
            
            indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            grayView.addSubview(indicator)
        }
        
        grayView.frame = self.view.bounds
        indicator.center = grayView.center
        
        indicator.startAnimating()
        self.view.addSubview(grayView)
    }
    
    func hideLoadingScreen() {
        if (grayView != nil) && (grayView.superview != nil) {
            indicator.stopAnimating()
            grayView.removeFromSuperview()
        }
    }
    
    
}

