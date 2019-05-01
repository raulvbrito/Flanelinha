//
//  VehicleViewController.swift
//  Flanelinha
//
//  Created by Raul Brito on 01/05/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit
import CoreData

class VehicleViewController: UIViewController {

	var vehicle: Vehicle?

	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var plateTextField: UITextField!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
        if let vehicle = vehicle {
        	nameTextField.text = vehicle.name
        	plateTextField.text = vehicle.plate
		}
    }
	
	@IBAction func save(_ sender: Any) {
		if vehicle == nil {
			vehicle = Vehicle(context: context)
		}
		vehicle?.name = nameTextField.text
		vehicle?.plate = plateTextField.text
		
		do {
			try context.save()
			navigationController?.popViewController(animated: true)
		} catch {
			print(error)
		}
	}
	
}
