//
//  StoryboardExtension.swift
//  Task_8
//
//  Created by Kirill Asyamolov on 17/01/17.
//  Copyright © 2017 Kirill Asyamolov. All rights reserved.
//

import UIKit

private let mainStoryboardName: String = "Main"


extension UIStoryboard {
    
    static var main: UIStoryboard {
        return UIStoryboard(name: mainStoryboardName, bundle: nil)
    }
    
    func viewControllerWithId(identifier: String) -> UIViewController {
        return instantiateViewController(withIdentifier: identifier)
    }
    
    func viewController<T: UIViewController>(type: T.Type) -> T {
        return viewControllerWithId(identifier: String(describing: type)) as! T
    }
    
    func navigationControllerWithId(identifier: String) -> UINavigationController! {
        if let nc = viewControllerWithId(identifier: identifier) as? UINavigationController {
            return nc
        }
        return nil
    }
}
