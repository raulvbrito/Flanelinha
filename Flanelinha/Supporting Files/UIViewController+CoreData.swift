//
//  UIViewController+CoreData.swift
//  Flanelinha
//
//  Created by Raul Brito on 01/05/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
