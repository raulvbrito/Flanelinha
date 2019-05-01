//
//  VehiclesViewController.swift
//  Flanelinha
//
//  Created by Raul Brito on 01/05/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit
import CoreData

class VehiclesViewController: UIViewController {

	var fetchedResultsController: NSFetchedResultsController<Vehicle>!
	
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        loadVehicles()
    }
	
    func loadVehicles() {
		let fetchRequest: NSFetchRequest<Vehicle> = Vehicle.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
		
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
		
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let indexPath = sender as? IndexPath, let vehicleVC = segue.destination as? VehicleViewController {
            vehicleVC.vehicle = fetchedResultsController.object(at: indexPath)
        }
    }
	
	@IBAction func addVehicle(_ sender: Any) {
		self.performSegue(withIdentifier: "vehicleSegue", sender: nil)
	}
	
	@IBAction func close(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
}

extension VehiclesViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.fetchedObjects?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleTableViewCell", for: indexPath) as? VehicleTableViewCell
		
		let vehicle = fetchedResultsController.object(at: indexPath)
		cell?.vehicleNameLabel.text = vehicle.name
		cell?.vehiclePlateLabel.text = vehicle.plate
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		self.performSegue(withIdentifier: "vehicleSegue", sender: indexPath)
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
            let vehicle = fetchedResultsController.object(at: indexPath)
            context.delete(vehicle)
            try? context.save()
        }
	}
}

extension VehiclesViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

