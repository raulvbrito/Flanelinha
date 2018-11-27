//
//  ViewController.swift
//  Flanelinha
//
//  Created by Raul Brito on 19/11/18.
//  Copyright © 2018 Raul Brito. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {

	// MARK: - Properties
	
	@IBOutlet weak var mapView: GMSMapView!
	@IBOutlet weak var searchTextField: UITextField!
	@IBOutlet weak var searchTextFieldTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchTextFieldLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchTextFieldHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var locationListView: UIView!
	@IBOutlet weak var locationListViewTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var locationListViewLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var locationListViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var locationTableView: UITableView!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
	
	let currentLocationMarker = GMSMarker()
	
	private let locationManager = CLLocationManager()
	
	let parkingMarker = GMSMarker()
	let parkingMarker2 = GMSMarker()
	let parkingMarker3 = GMSMarker()
	let parkingMarker4 = GMSMarker()
	
	private let parkingMarkerView = Bundle.main.loadNibNamed("ParkingMarkerView", owner: nil, options: nil)?.first as! ParkingMarkerView
	
	private var lastLocation: CLLocation?
	
	private var currentLocationMarkerShadowLayer: CAShapeLayer!
	
	private var locations: [GMSAutocompletePrediction] = []
	
	private var translationY: CGFloat = 0.0
	
    private var lastDragged: CGFloat = 0.0
	
	private var snapToMostVisibleColumnVelocityThreshold: CGFloat { return 0.3 }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		  return .lightContent
	}
	
	
	// MARK: - Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		
		configureMapStyle()
		createPanGestureRecognizer(targetView: locationListView)
	}
	
	func configureMapStyle() {
		do {
			if let styleURL = Bundle.main.url(forResource: "dark", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find dark.json")
            }
		} catch {
			print("Map style not applied")
		}
		
		let currentLocationMarkerView = CurrentLocationMarkerView()
		currentLocationMarkerView.frame.size = CGSize(width: 17, height: 17)
		currentLocationMarkerView.layer.cornerRadius = 8.5
		currentLocationMarkerView.layer.borderColor = UIColor.white.cgColor
		currentLocationMarkerView.layer.borderWidth = 1.5
		currentLocationMarkerView.clipsToBounds = false
		currentLocationMarkerView.backgroundColor = UIColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 1)

		currentLocationMarker.iconView = currentLocationMarkerView
		currentLocationMarker.map = mapView
		currentLocationMarker.appearAnimation = GMSMarkerAnimation.pop
		
		parkingMarkerView.priceLabel.text = "R$ " + String(Int.random(in: 10..<30)) + "," + String(Int.random(in: 00..<99))
		parkingMarker.iconView = parkingMarkerView
		parkingMarker.map = mapView
		parkingMarker.appearAnimation = GMSMarkerAnimation.pop
		
		parkingMarkerView.priceLabel.text = "R$ " + String(Int.random(in: 10..<30)) + "," + String(Int.random(in: 00..<99))
		parkingMarker2.iconView = parkingMarkerView
		parkingMarker2.map = mapView
		parkingMarker2.appearAnimation = GMSMarkerAnimation.pop
		
		parkingMarkerView.priceLabel.text = "R$ " + String(Int.random(in: 10..<30)) + "," + String(Int.random(in: 00..<99))
		parkingMarker3.iconView = parkingMarkerView
		parkingMarker3.map = mapView
		parkingMarker3.appearAnimation = GMSMarkerAnimation.pop
		
		parkingMarkerView.priceLabel.text = "R$ " + String(Int.random(in: 10..<30)) + "," + String(Int.random(in: 00..<99)) + "/h"
		parkingMarker4.iconView = parkingMarkerView
		parkingMarker4.map = mapView
		parkingMarker4.appearAnimation = GMSMarkerAnimation.pop
	}
	
	func placeAutocomplete(searchText: String) {
		let filter = GMSAutocompleteFilter()
		filter.country = "BR"
		
		let placesClient = GMSPlacesClient()
		placesClient.autocompleteQuery(searchText, bounds: nil, filter: filter, callback: {(results, error) -> Void in
			if let error = error {
				print("Autocomplete error \(error)")
				return
			}
			if let results = results {
				self.locations = results
				for result in results {
					print("Result \(result.attributedFullText) with placeID \(String(describing: result.placeID))")
				}
				
				self.locationTableView.reloadData()
			}
		})
	}
	
	func createPanGestureRecognizer(targetView: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(panGesture:)))
        targetView.addGestureRecognizer(panGesture)
    }
	
	@objc func handlePanGesture(panGesture: UIPanGestureRecognizer) {
		self.searchTextField.resignFirstResponder()
	
        let translation = panGesture.translation(in: view)
        panGesture.setTranslation(CGPoint.zero, in: view)
		
        locationListView.layoutIfNeeded()
        self.view.layoutIfNeeded()
		
        translationY = translation.y
		
        if self.lastDragged < translation.y && self.locationListViewTopConstraint.constant >= 0 {
            translationY = 0.0
        }
		
		if panGesture.state == UIGestureRecognizer.State.began {
            print(panGesture)
			
//            self.locationsViewTopShadow.isHidden = false
        }
		
		if panGesture.state == UIGestureRecognizer.State.ended {
            print(panGesture)
			
//            self.readyButton.isHidden = false
			
			UIView.animate(withDuration: 0.2, delay: 0, animations: {
                if self.locationListViewTopConstraint.constant >= 200 {
                    self.locationListViewTopConstraint.constant = 500
                    self.locationListViewLeadingConstraint.constant = 10
					
//                    self.locationsViewTopShadow.alpha = 0
                } else {
                    self.locationListViewTopConstraint.constant = 0
                    self.locationListViewLeadingConstraint.constant = 0
					
//                    self.locationsViewTopShadow.alpha = 1
                }
				
				self.locationListView.layoutIfNeeded()
				self.view.layoutIfNeeded()
            }, completion: nil)
        }
		
		if panGesture.state == UIGestureRecognizer.State.changed {
            print(panGesture)
			
			UIView.animate(withDuration: 0.1, delay: 0, animations: {
                self.locationListViewTopConstraint.constant += translation.y
                self.locationListViewLeadingConstraint.constant += translation.y/30
				
//                self.locationsViewTopShadow.alpha -= translation.y/100
				
				self.locationListView.layoutIfNeeded()
				self.view.layoutIfNeeded()
            }, completion: nil)
			
            self.lastDragged = translation.y
        } else {
			
        }
    }
	
    func closeSearch() {
		self.searchTextFieldTopConstraint.constant = 60
		self.searchTextFieldLeadingConstraint.constant = 24
		self.searchTextFieldHeightConstraint.constant = 60
		self.collectionViewBottomConstraint.constant = 23
		
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
		
		searchTextField.resignFirstResponder()
    }
	
	@IBAction func goToMyLocation(_ sender: UIButton) {
		self.mapView.animate(to: GMSCameraPosition(target: self.mapView.myLocation?.coordinate ?? lastLocation!.coordinate, zoom: 16, bearing: 0, viewingAngle: 0))
	}
	
	@IBAction func locationSearchOpen(_ sender: Any) {
		self.searchTextFieldTopConstraint.constant = -45
		self.searchTextFieldLeadingConstraint.constant = 0
		self.searchTextFieldHeightConstraint.constant = 120
		self.collectionViewBottomConstraint.constant = -250
		
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
	}
	
	@IBAction func locationSearch(_ sender: UITextField) {
		self.locationListViewTopConstraint.constant = 0
		
		UIView.animate(withDuration: 0.2) {
			self.view.layoutIfNeeded()
		}
		
		placeAutocomplete(searchText: searchTextField.text ?? "")
	}
	
	
}


// MARK: - GMSMapViewDelegate

extension MapViewController: GMSMapViewDelegate {

	func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
		closeSearch()
	}
	
	func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
		searchTextField.resignFirstResponder()
	}
	
}


// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		guard status == .authorizedWhenInUse else {
		  return
		}
	
		locationManager.startUpdatingLocation()

		mapView.isMyLocationEnabled = false
		mapView.settings.myLocationButton = false
		
		let padding = UIEdgeInsets(top: 0, left: 23, bottom: 190, right: 21)
		mapView.padding = padding
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else {
		  return
		}
		
		if lastLocation == nil {
			mapView.animate(to: GMSCameraPosition(target: location.coordinate, zoom: 16, bearing: 0, viewingAngle: 0))
			
			CATransaction.begin()
			CATransaction.setAnimationDuration(0.5)
			currentLocationMarker.position = location.coordinate
			currentLocationMarker.rotation = location.course
			CATransaction.commit()
			
			parkingMarker.position = CLLocationCoordinate2DMake(location.coordinate.latitude + 0.001, location.coordinate.longitude - 0.001)
			parkingMarker2.position = CLLocationCoordinate2DMake(location.coordinate.latitude - 0.001, location.coordinate.longitude + 0.002)
			parkingMarker3.position = CLLocationCoordinate2DMake(location.coordinate.latitude - 0.003, location.coordinate.longitude + 0.002)
			parkingMarker4.position = CLLocationCoordinate2DMake(location.coordinate.latitude - 0.0015, location.coordinate.longitude - 0.002)
		}
		
		lastLocation = location
	}
	
	
}


// MARK: - UICollectionViewDelegate

extension MapViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return locations.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as? LocationTableViewCell
		
		let bgColorView = UIView()
		bgColorView.backgroundColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
		cell?.selectedBackgroundView = bgColorView
		
		if locations.count > indexPath.row {
			cell?.locationNameLabel.text = locations[indexPath.row].attributedPrimaryText.string
			cell?.locationAddressLabel.text = locations[indexPath.row].attributedSecondaryText?.string
		} else {
			cell?.locationNameLabel.text = "Defina o local no mapa"
			cell?.locationAddressLabel.text = ""
		}
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		locationTableView.deselectRow(at: indexPath, animated: true)
		
//		locations[indexPath.row].
//		print(GMSPlacesClient.lookUpPlaceID(locations[indexPath.row].placeID ))
	}
}


// MARK: - UICollectionViewDelegate

extension MapViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width - 140, height: 150)
    }
	
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		
//        if scrollView is UICollectionView {
//			let pageWidth: Float = Float(collectionView.frame.width - 140 + 20)
//			let currentOffset: Float = Float(scrollView.contentOffset.x)
//			let targetOffset: Float = Float(targetContentOffset.pointee.x)
//			var newTargetOffset: Float = 0
//
//			if targetOffset > currentOffset {
//				newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth
//			} else {
//				newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth
//			}
//
//			if newTargetOffset < 0 {
//				newTargetOffset = 0
//			} else if (newTargetOffset > Float(scrollView.contentSize.width)){
//				newTargetOffset = Float(Float(scrollView.contentSize.width))
//			}
//
//			targetContentOffset.pointee.x = CGFloat(currentOffset)
//			scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: scrollView.contentOffset.y), animated: false)
//        }

		let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
		let bounds = scrollView.bounds
		let xTarget = targetContentOffset.pointee.x

		let xMax = scrollView.contentSize.width - scrollView.bounds.width

		if abs(velocity.x) <= snapToMostVisibleColumnVelocityThreshold {
			let xCenter = scrollView.bounds.midX
			let poses = layout.layoutAttributesForElements(in: bounds) ?? []
			let x = poses.min(by: { abs($0.center.x - xCenter) < abs($1.center.x - xCenter) })?.frame.origin.x ?? 0
			targetContentOffset.pointee.x = x - 30
		} else if velocity.x > 0 {
			let poses = layout.layoutAttributesForElements(in: CGRect(x: xTarget, y: 0, width: bounds.size.width, height: bounds.size.height)) ?? []
			let xCurrent = scrollView.contentOffset.x
			let x = poses.filter({ $0.frame.origin.x > xCurrent}).min(by: { $0.center.x < $1.center.x })?.frame.origin.x ?? xMax
			targetContentOffset.pointee.x = min(x - 30, xMax)
		} else {
			let poses = layout.layoutAttributesForElements(in: CGRect(x: xTarget - bounds.size.width, y: 0, width: bounds.size.width, height: bounds.size.height)) ?? []
			let x = poses.max(by: { $0.center.x < $1.center.x })?.frame.origin.x ?? 0
			targetContentOffset.pointee.x = max(x - 30, 0)
		}
    }
	
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 15
    }
	
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCollectionViewCell", for: indexPath) as? OptionCollectionViewCell
		
//		cell?.setGradientBackground(colorTop: UIColor(red: 255/255, green: 140/255, blue: 0/255, alpha: 1), colorBottom: UIColor(red: 255/255, green: 200/255, blue: 0/255, alpha: 1))
		cell?.layer.cornerRadius = 6
//		cell?.gradientView.backgroundColor = .clear
//		cell?.titleLabel.textColor = .white
//		cell?.countLabel.textColor = .white
		cell?.optionIconView.layer.borderColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1).cgColor
		
		return cell!
    }
	
}

extension UIView {
	func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
		gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
		gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.2)
		gradientLayer.locations = [0, 1]
		gradientLayer.frame = bounds

	   layer.insertSublayer(gradientLayer, at: 0)
	}
}
