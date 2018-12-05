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
import MapboxGeocoder

enum PulsingViewAnimation: String {
	case animating
	case notAnimating
}

enum SearchStatus: String {
	case searchClosed
	case searchOpen
	case searching
	case resultSelected
}

class MapViewController: UIViewController {

	// MARK: - Properties
	
	@IBOutlet weak var mapView: GMSMapView!
	
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var backButtonLeadingConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var pulsingView: UIView!
	@IBOutlet weak var pulsingViewLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var loadingViewLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var loadingViewTopConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var searchView: UIView!
	@IBOutlet weak var searchTextField: UITextField!
	@IBOutlet weak var searchTextFieldTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchTextFieldBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchTextFieldLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchTextFieldHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var locationTypeLabel: UILabel!
	@IBOutlet weak var locationTypeLabelTopConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var addressLabelBottomConstraint: NSLayoutConstraint!
	
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
	
	let selectedParkingMarker = GMSMarker()
	
	private let geocoder = Geocoder.shared
	
	private let parkingMarkerView = Bundle.main.loadNibNamed("ParkingMarkerView", owner: nil, options: nil)?.first as! ParkingMarkerView
	
	private let selectedParkingMarkerView = Bundle.main.loadNibNamed("SelectedParkingMarkerView", owner: nil, options: nil)?.first as! SelectedParkingMarkerView
	
	private var lastLocation: CLLocation?
	
	private var currentLocationMarkerShadowLayer: CAShapeLayer!
	
	private var pulsingViewAnimation: PulsingViewAnimation! = .notAnimating
	
	private var searchStatus: SearchStatus! = .searchClosed
	
//	private var locations: [GMSAutocompletePrediction] = []
	private var locations: [Location] = []
	
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
		
		let backIconImage = UIImage(named: "back_icon")
		let tintedImage = backIconImage?.withRenderingMode(.alwaysTemplate)
		backButton.setImage(tintedImage, for: .normal)
		backButton.tintColor = .white
		
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
		
		selectedParkingMarker.iconView = selectedParkingMarkerView
		selectedParkingMarker.map = mapView
		selectedParkingMarker.appearAnimation = GMSMarkerAnimation.pop
	}
	
	func placeAutocomplete(searchText: String) {
		loadingViewTopConstraint.constant = -15
		loadingViewLeadingConstraint.constant = -15
		
		UIView.animate(withDuration: 0.4) {
			self.view.layoutIfNeeded()
		}
		
		let cornerAnimation: CABasicAnimation = CABasicAnimation(keyPath:"cornerRadius")
		
		let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")

		if pulsingViewAnimation == PulsingViewAnimation.notAnimating {
			pulsingViewAnimation = PulsingViewAnimation.animating
		
			cornerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
			cornerAnimation.fromValue = pulsingView.layer.cornerRadius
			cornerAnimation.toValue = 4
			cornerAnimation.duration = 0.8

			scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
			scaleAnimation.duration = 0.4
			scaleAnimation.repeatCount = 30.0
			scaleAnimation.autoreverses = true
			scaleAnimation.fromValue = 1.0;
			scaleAnimation.toValue = 0.8;
			
			pulsingView.layer.add(cornerAnimation, forKey: "cornerRadius")
			pulsingView.layer.cornerRadius = 4
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				self.pulsingView.layer.add(scaleAnimation, forKey: "scale")
				self.pulsingView.layer.removeAnimation(forKey: "cornerRadius")
			}
		}

		let options = ForwardGeocodeOptions(query: searchText)
		
        options.allowedISOCountryCodes = ["BR"]
        options.focalLocation = CLLocation(latitude: lastLocation?.coordinate.latitude ?? 0, longitude: lastLocation?.coordinate.longitude ?? 0)
        options.allowedScopes = [.address, .pointOfInterest, .landmark]
		
        let task = geocoder.geocode(options) { (placemarks, attribution, error) in
            if let placemarks = placemarks {
                self.locations.removeAll()
				
                var location = [
                    "title": "",
                    "subtitle": "",
                    "genre": "",
                    "isAffiliate": false,
                    "latitude": 0,
                    "longitude": 0
                    ] as [String : Any]
				
                for placemark in placemarks {
					
                    var subtitle = ""
					
                    if #available(iOS 10.3, *) {
						if placemark.postalAddress?.street != "" {
							subtitle += placemark.postalAddress?.street ?? ""
						}
						
                        if placemark.postalAddress?.subLocality != "" {
                        	if subtitle != "" {
								subtitle += ", "
							}
							
                            subtitle += placemark.postalAddress!.subLocality
                        }
						
                        if placemark.postalAddress?.subAdministrativeArea != "" {
                            if subtitle != "" {
                                subtitle += ", "
                            }
							
                            subtitle += placemark.postalAddress!.subAdministrativeArea
                        }
                    }
					
                    if placemark.postalAddress?.city != "" {
                        if subtitle != "" {
                            subtitle += ", "
                        }
						
                        subtitle += placemark.postalAddress!.city
                    }
					
                    if placemark.postalAddress?.state != "" {
//                        if subtitle != "" {
//                            subtitle += " - "
//                        }
						
//                        subtitle += placemark.postalAddress!.state
                    }
					
                    location["title"] = placemark.formattedName
                    location["subtitle"] = subtitle
					location["genre"] = placemark.genres?[0]
					location["isAffiliate"] = Bool.random()
					location["latitude"] = placemark.location?.coordinate.latitude
					location["longitude"] = placemark.location?.coordinate.longitude
					location["location"] = CLLocationCoordinate2D(latitude: placemark.location?.coordinate.latitude ?? 0, longitude: placemark.location?.coordinate.longitude ?? 0)
					
                    self.locations.append(Location(location))
                }
				
//				scaleAnimation.duration = 0.8
//				scaleAnimation.repeatCount = 1
//				scaleAnimation.autoreverses = true
//				scaleAnimation.fromValue = self.pulsingView.layer.contentsScale;
//				scaleAnimation.toValue = 1;

				if self.pulsingViewAnimation == PulsingViewAnimation.animating {
					self.pulsingViewAnimation = PulsingViewAnimation.notAnimating
					
					DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
						cornerAnimation.fromValue = self.pulsingView.layer.cornerRadius
						cornerAnimation.toValue = 0
						cornerAnimation.duration = 0.8
						
						self.pulsingView.layer.add(scaleAnimation, forKey: "scale")
						
						self.loadingViewTopConstraint.constant = -4
						self.loadingViewLeadingConstraint.constant = -4
						
						UIView.animate(withDuration: 0.4) {
							self.view.layoutIfNeeded()
						}
						
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
							self.pulsingView.layer.add(cornerAnimation, forKey: "cornerRadius")
							self.pulsingView.layer.cornerRadius = 0
							
							self.pulsingView.layer.removeAnimation(forKey: "scale")
//							self.pulsingView.layer.removeAllAnimations()
						}
					}
				}
				
                self.locationTableView.reloadData()
            }
        }
		
        task.resume()
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
//            print(panGesture)
        }
		
		if panGesture.state == UIGestureRecognizer.State.ended {
			UIView.animate(withDuration: 0.2, delay: 0, animations: {
                if self.locationListViewTopConstraint.constant >= 200 {
                    self.locationListViewTopConstraint.constant = 550
                    self.locationListViewLeadingConstraint.constant = 10
                } else {
                    self.locationListViewTopConstraint.constant = 0
                    self.locationListViewLeadingConstraint.constant = 0
                }
				
				self.locationListView.layoutIfNeeded()
				self.view.layoutIfNeeded()
            }, completion: nil)
        }
		
		if panGesture.state == UIGestureRecognizer.State.changed {
            print(panGesture)
			
			self.locationListViewTopConstraint.constant += translation.y
			self.locationListViewLeadingConstraint.constant += translation.y/30
			
//			UIView.animate(withDuration: 0.01, delay: 0, animations: {
////                self.locationsViewTopShadow.alpha -= translation.y/100
//
//				self.locationListView.layoutIfNeeded()
//				self.view.layoutIfNeeded()
//            }, completion: nil)
			
            self.lastDragged = translation.y
        } else {
			
        }
    }
	
    func closeSearch() {
		searchStatus = .searchClosed
		
    	self.searchTextField.isUserInteractionEnabled = true
		
		self.backButtonLeadingConstraint.constant = -30
    	self.pulsingViewLeadingConstraint.constant = 20
		self.searchTextFieldTopConstraint.constant = 60
		self.searchTextFieldBottomConstraint.constant = 8
		self.searchTextFieldLeadingConstraint.constant = 24
		self.searchTextFieldHeightConstraint.constant = 60
		self.locationTypeLabelTopConstraint.constant = 0
		self.addressLabelBottomConstraint.constant = 0
		self.collectionViewBottomConstraint.constant = 23
		self.locationListViewTopConstraint.constant = 750
		self.locationListViewLeadingConstraint.constant = 0
		
		self.searchTextField.resignFirstResponder()
		
		UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
			self.searchTextField.transform = CGAffineTransform.identity
			self.searchView.backgroundColor = .darkGray
			
			self.locationTypeLabel.alpha = 0
			self.addressLabel.alpha = 0
			
			self.view.layoutIfNeeded()
		})
    }
	
	@IBAction func goToMyLocation(_ sender: UIButton) {
		self.mapView.animate(to: GMSCameraPosition(target: self.mapView.myLocation?.coordinate ?? lastLocation!.coordinate, zoom: 16, bearing: 0, viewingAngle: 0))
	}
	
	@IBAction func locationSearchOpen(_ sender: Any) {
		searchStatus = .searchOpen
		
		self.backButtonLeadingConstraint.constant = -30
		self.pulsingViewLeadingConstraint.constant = 20
		self.searchTextFieldTopConstraint.constant = -45
		self.searchTextFieldLeadingConstraint.constant = 0
		self.searchTextFieldHeightConstraint.constant = 120
		self.collectionViewBottomConstraint.constant = -250
		
		UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
			self.searchView.backgroundColor = .darkGray
			
			self.view.layoutIfNeeded()
		})
	}
	
	@IBAction func locationSearch(_ sender: UITextField) {
		searchStatus = .searching
	
		self.locationListViewTopConstraint.constant = 0
		self.locationListViewLeadingConstraint.constant = 0
		
		UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
			self.view.layoutIfNeeded()
		})
		
		placeAutocomplete(searchText: searchTextField.text ?? "")
	}
	
	@IBAction func goBack(_ sender: Any) {
		closeSearch()
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


// MARK: - UITableViewDelegate

extension MapViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return locations.count + 1
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 65
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as? LocationTableViewCell
		
		let bgColorView = UIView()
		bgColorView.backgroundColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
		cell?.selectedBackgroundView = bgColorView
		
		cell?.affiliateParkingSymbolView.setGradientBackground(colorTop: UIColor(red: 255/255, green: 140/255, blue: 0/255, alpha: 1), colorBottom: UIColor(red: 255/255, green: 200/255, blue: 0/255, alpha: 1))
		
		if locations.count > indexPath.row {
			cell?.locationNameLabel.text = self.locations[indexPath.row].title
			cell?.locationAddressLabel.text = self.locations[indexPath.row].subtitle
			
			cell?.locationAddressLabel.isHidden = false
			
			if self.locations[indexPath.row].genre == "parking" {
				cell?.locationSymbolImageView.isHidden = true
				cell?.parkingSymbolView.isHidden = false
				
				cell?.locationSymbolImageView.isHidden = true
			
				cell?.parkingSymbolView.isHidden = self.locations[indexPath.row].isAffiliate
				cell?.affiliateParkingSymbolView.isHidden = !self.locations[indexPath.row].isAffiliate
			} else {
				cell?.locationSymbolImageView.isHidden = false
				cell?.parkingSymbolView.isHidden = true
				cell?.affiliateParkingSymbolView.isHidden = true
			}
		} else {
			cell?.locationSymbolImageView.isHidden = false
			cell?.locationNameLabel.text = "Defina o local no mapa"
			cell?.locationAddressLabel.text = ""
			cell?.locationAddressLabel.isHidden = true
		}
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		locationTableView.deselectRow(at: indexPath, animated: true)
		
		collectionView.reloadData()
		
		self.searchTextField.resignFirstResponder()
		
		if self.locations[indexPath.row].genre == "parking" {
			searchStatus = .resultSelected
		
			self.searchTextField.text = self.locations[indexPath.row].title
			self.searchTextField.isUserInteractionEnabled = false
			
			self.locationTypeLabel.text = "Estacionamento"
			self.addressLabel.text = self.locations[indexPath.row].subtitle
			
			self.backButtonLeadingConstraint.constant = 16
			self.pulsingViewLeadingConstraint.constant = -10
			self.searchTextFieldBottomConstraint.constant = 26
			self.searchTextFieldHeightConstraint.constant = 200
			self.collectionViewBottomConstraint.constant = 23
			self.locationListViewTopConstraint.constant = 750
			self.locationListViewLeadingConstraint.constant = 0
			
			let originalTransform = self.searchTextField.transform
			let scaledTransform = originalTransform.scaledBy(x: 1.3, y: 1.3)
			let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: 45, y: 0)
	
			UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
				self.searchTextField.transform = scaledAndTranslatedTransform
				
				if self.locations[indexPath.row].isAffiliate {
					self.searchView.backgroundColor = UIColor(red: 255/255, green: 140/255, blue: 0/255, alpha: 1)
				} else {
					self.searchView.backgroundColor = .white
				}
				
				self.view.layoutIfNeeded()
			}, completion: { (Bool) in
				self.locationTypeLabelTopConstraint.constant = -12
				self.addressLabelBottomConstraint.constant = 14
				
				UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
					self.locationTypeLabel.alpha = 1
					self.addressLabel.alpha = 1
					
					self.view.layoutIfNeeded()
				})
			})
		}
		
		selectedParkingMarker.position = locations[indexPath.row].location
		mapView.animate(to: GMSCameraPosition(target: locations[indexPath.row].location, zoom: 16, bearing: 0, viewingAngle: 0))
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
