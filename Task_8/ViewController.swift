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
        showLoadingScreen()
        
        textField.resignFirstResponder()
        
        if let userName = self.textField.text {
            controller.getAvatar(for: userName,
                                 success: {image in self.imageView.image = image},
                                 failure: {error in print(error.localizedDescription)})
        } else {
            print("Please enter the nickname.")
        }
    }
    
    func showLoadingScreen() {
        let grayView = UIView(frame: self.view.bounds)
        grayView.backgroundColor = UIColor(white: CGFloat(0), alpha: CGFloat(0.5))
        self.view.addSubview(grayView)
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.center = grayView.center
        indicator.startAnimating()
        grayView.addSubview(indicator)
    }
    
    
}

