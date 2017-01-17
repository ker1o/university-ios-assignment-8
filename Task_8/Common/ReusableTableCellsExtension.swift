//
//  ReusablesExtension.swift
//  Task_8
//
//  Created by Kirill Asyamolov on 17/01/17.
//  Copyright © 2017 Kirill Asyamolov. All rights reserved.
//

import UIKit

protocol CellReuseIdentifierProvider: class {
    static var reuseIdentifier: String { get }
}

extension CellReuseIdentifierProvider {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

protocol NibProvider: CellReuseIdentifierProvider {
    static var nib: UINib? { get }
}

extension NibProvider {
    static var nib: UINib? {
        return UINib(nibName: reuseIdentifier, bundle: Bundle.main)
    }
}

extension UICollectionReusableView: NibProvider {}
extension UITableViewCell: NibProvider {}
