//
//  ViewController.swift
//  Flanelinha
//
//  Created by Raul Brito on 19/11/18.
//  Copyright © 2018 Raul Brito. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import MapboxDirections
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
	
	private let directions = Directions.shared
	
	private let geocoder = Geocoder.shared
	
	private let parkingMarkerView = Bundle.main.loadNibNamed("ParkingMarkerView", owner: nil, options: nil)?.first as! ParkingMarkerView
	
	private let selectedParkingMarkerView = Bundle.main.loadNibNamed("SelectedParkingMarkerView", owner: nil, options: nil)?.first as! SelectedParkingMarkerView
	
	private let playerMarkerView = Bundle.main.loadNibNamed("PlayerMarkerView", owner: nil, options: nil)?.first as! PlayerMarkerView
	
	lazy var playerRef: DatabaseReference = Database.database().reference().child("players")
	
	private var playerRefHandle: DatabaseHandle?
	
	private var players: [Player] = []
	
	private var playerMarkers = [GMSMarker()]
	
	private var playersCoordinates: [[CLLocationCoordinate2D]] = [
	 [
	 CLLocationCoordinate2D(latitude: -23.57306, longitude: -46.66266),
	 CLLocationCoordinate2D(latitude: -23.57259, longitude: -46.66212),
	 CLLocationCoordinate2D(latitude: -23.572490000000002, longitude: -46.662220000000005),
	 CLLocationCoordinate2D(latitude: -23.572350000000004, longitude: -46.66212),
	 CLLocationCoordinate2D(latitude: -23.563750000000002, longitude: -46.65382),
	 CLLocationCoordinate2D(latitude: -23.56406, longitude: -46.65345000000001),
	 CLLocationCoordinate2D(latitude: -23.563930000000003, longitude: -46.65332000000001),
	 CLLocationCoordinate2D(latitude: -23.56388, longitude: -46.653380000000006),
	 CLLocationCoordinate2D(latitude: -23.56387, longitude: -46.653040000000004),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.57521, longitude: -46.657),
	 CLLocationCoordinate2D(latitude: -23.57463, longitude: -46.656369999999995),
	 CLLocationCoordinate2D(latitude: -23.57322, longitude: -46.657889999999995),
	 CLLocationCoordinate2D(latitude: -23.572309999999998, longitude: -46.65698999999999),
	 CLLocationCoordinate2D(latitude: -23.57106, longitude: -46.65825999999999),
	 CLLocationCoordinate2D(latitude: -23.564989999999998, longitude: -46.65233999999999),
	 CLLocationCoordinate2D(latitude: -23.56458, longitude: -46.65281999999999),
	 CLLocationCoordinate2D(latitude: -23.56445, longitude: -46.65268999999999),
	 CLLocationCoordinate2D(latitude: -23.56429, longitude: -46.65285999999999),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56716, longitude: -46.66831),
	 CLLocationCoordinate2D(latitude: -23.567410000000002, longitude: -46.668),
	 CLLocationCoordinate2D(latitude: -23.562990000000003, longitude: -46.6624),
	 CLLocationCoordinate2D(latitude: -23.562680000000004, longitude: -46.65891),
	 CLLocationCoordinate2D(latitude: -23.56199, longitude: -46.65781),
	 CLLocationCoordinate2D(latitude: -23.56222, longitude: -46.657219999999995),
	 CLLocationCoordinate2D(latitude: -23.56207, longitude: -46.656729999999996),
	 CLLocationCoordinate2D(latitude: -23.56194, longitude: -46.656),
	 CLLocationCoordinate2D(latitude: -23.562669999999997, longitude: -46.65484),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56206, longitude: -46.66969),
	 CLLocationCoordinate2D(latitude: -23.56024, longitude: -46.667770000000004),
	 CLLocationCoordinate2D(latitude: -23.56253, longitude: -46.66292),
	 CLLocationCoordinate2D(latitude: -23.56347, longitude: -46.66158),
	 CLLocationCoordinate2D(latitude: -23.56268, longitude: -46.65891),
	 CLLocationCoordinate2D(latitude: -23.562649999999998, longitude: -46.65861),
	 CLLocationCoordinate2D(latitude: -23.561989999999998, longitude: -46.65781),
	 CLLocationCoordinate2D(latitude: -23.562069999999995, longitude: -46.656729999999996),
	 CLLocationCoordinate2D(latitude: -23.562729999999995, longitude: -46.6549),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56308, longitude: -46.66223),
	 CLLocationCoordinate2D(latitude: -23.56347, longitude: -46.66158),
	 CLLocationCoordinate2D(latitude: -23.56268, longitude: -46.65891),
	 CLLocationCoordinate2D(latitude: -23.561989999999998, longitude: -46.65781),
	 CLLocationCoordinate2D(latitude: -23.562219999999996, longitude: -46.656929999999996),
	 CLLocationCoordinate2D(latitude: -23.562219999999996, longitude: -46.65636),
	 CLLocationCoordinate2D(latitude: -23.562729999999995, longitude: -46.6549),
	 CLLocationCoordinate2D(latitude: -23.563879999999994, longitude: -46.65338),
	 CLLocationCoordinate2D(latitude: -23.563989999999993, longitude: -46.65291),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.57351, longitude: -46.64867),
	 CLLocationCoordinate2D(latitude: -23.5734, longitude: -46.64837),
	 CLLocationCoordinate2D(latitude: -23.57132, longitude: -46.65106),
	 CLLocationCoordinate2D(latitude: -23.56924, longitude: -46.64929),
	 CLLocationCoordinate2D(latitude: -23.56794, longitude: -46.64897),
	 CLLocationCoordinate2D(latitude: -23.56777, longitude: -46.64881),
	 CLLocationCoordinate2D(latitude: -23.564519999999998, longitude: -46.65276),
	 CLLocationCoordinate2D(latitude: -23.564449999999997, longitude: -46.65269),
	 CLLocationCoordinate2D(latitude: -23.564289999999996, longitude: -46.65286),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.57445, longitude: -46.64647),
	 CLLocationCoordinate2D(latitude: -23.572889999999997, longitude: -46.64722),
	 CLLocationCoordinate2D(latitude: -23.5705, longitude: -46.65036),
	 CLLocationCoordinate2D(latitude: -23.56924, longitude: -46.64929),
	 CLLocationCoordinate2D(latitude: -23.56794, longitude: -46.64897),
	 CLLocationCoordinate2D(latitude: -23.56777, longitude: -46.64881),
	 CLLocationCoordinate2D(latitude: -23.564519999999998, longitude: -46.65276),
	 CLLocationCoordinate2D(latitude: -23.564449999999997, longitude: -46.65269),
	 CLLocationCoordinate2D(latitude: -23.564289999999996, longitude: -46.65286),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56162, longitude: -46.64163),
	 CLLocationCoordinate2D(latitude: -23.562330000000003, longitude: -46.64184),
	 CLLocationCoordinate2D(latitude: -23.561680000000003, longitude: -46.64443),
	 CLLocationCoordinate2D(latitude: -23.56548, longitude: -46.647619999999996),
	 CLLocationCoordinate2D(latitude: -23.56512, longitude: -46.648059999999994),
	 CLLocationCoordinate2D(latitude: -23.5653, longitude: -46.64872999999999),
	 CLLocationCoordinate2D(latitude: -23.565170000000002, longitude: -46.64983999999999),
	 CLLocationCoordinate2D(latitude: -23.566070000000003, longitude: -46.65073999999999),
	 CLLocationCoordinate2D(latitude: -23.564340000000005, longitude: -46.652829999999994),
	 CLLocationCoordinate2D(latitude: -23.564110000000007, longitude: -46.65286999999999)],
	 [
	 CLLocationCoordinate2D(latitude: -23.55945, longitude: -46.64422),
	 CLLocationCoordinate2D(latitude: -23.56122, longitude: -46.644029999999994),
	 CLLocationCoordinate2D(latitude: -23.565479999999997, longitude: -46.647619999999996),
	 CLLocationCoordinate2D(latitude: -23.565119999999997, longitude: -46.648059999999994),
	 CLLocationCoordinate2D(latitude: -23.565299999999997, longitude: -46.64872999999999),
	 CLLocationCoordinate2D(latitude: -23.56573, longitude: -46.64916999999999),
	 CLLocationCoordinate2D(latitude: -23.56517, longitude: -46.64983999999999),
	 CLLocationCoordinate2D(latitude: -23.56607, longitude: -46.65073999999999),
	 CLLocationCoordinate2D(latitude: -23.56434, longitude: -46.652829999999994),
	 CLLocationCoordinate2D(latitude: -23.564110000000003, longitude: -46.65286999999999)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56795, longitude: -46.64218),
	 CLLocationCoordinate2D(latitude: -23.56852, longitude: -46.64217),
	 CLLocationCoordinate2D(latitude: -23.568369999999998, longitude: -46.64356),
	 CLLocationCoordinate2D(latitude: -23.568129999999996, longitude: -46.64414),
	 CLLocationCoordinate2D(latitude: -23.566539999999996, longitude: -46.64521),
	 CLLocationCoordinate2D(latitude: -23.565479999999994, longitude: -46.647619999999996),
	 CLLocationCoordinate2D(latitude: -23.565299999999993, longitude: -46.64872999999999),
	 CLLocationCoordinate2D(latitude: -23.565169999999995, longitude: -46.64983999999999),
	 CLLocationCoordinate2D(latitude: -23.564339999999998, longitude: -46.652829999999994),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.65286999999999)],
	 [
	 CLLocationCoordinate2D(latitude: -23.57367, longitude: -46.6691),
	 CLLocationCoordinate2D(latitude: -23.57021, longitude: -46.66427),
	 CLLocationCoordinate2D(latitude: -23.56207, longitude: -46.65585),
	 CLLocationCoordinate2D(latitude: -23.562359999999998, longitude: -46.6555),
	 CLLocationCoordinate2D(latitude: -23.562289999999997, longitude: -46.65543),
	 CLLocationCoordinate2D(latitude: -23.56273, longitude: -46.654900000000005),
	 CLLocationCoordinate2D(latitude: -23.562669999999997, longitude: -46.65484000000001),
	 CLLocationCoordinate2D(latitude: -23.563879999999997, longitude: -46.653380000000006),
	 CLLocationCoordinate2D(latitude: -23.563869999999998, longitude: -46.653040000000004),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.65287000000001)],
	 [
	 CLLocationCoordinate2D(latitude: -23.57457, longitude: -46.65277),
	 CLLocationCoordinate2D(latitude: -23.573970000000003, longitude: -46.65358),
	 CLLocationCoordinate2D(latitude: -23.573080000000004, longitude: -46.65278),
	 CLLocationCoordinate2D(latitude: -23.569240000000004, longitude: -46.64929),
	 CLLocationCoordinate2D(latitude: -23.567940000000004, longitude: -46.64897),
	 CLLocationCoordinate2D(latitude: -23.567770000000003, longitude: -46.64881),
	 CLLocationCoordinate2D(latitude: -23.56452, longitude: -46.65276),
	 CLLocationCoordinate2D(latitude: -23.56445, longitude: -46.65269),
	 CLLocationCoordinate2D(latitude: -23.56429, longitude: -46.65286),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.57472, longitude: -46.64318),
	 CLLocationCoordinate2D(latitude: -23.57469, longitude: -46.64311),
	 CLLocationCoordinate2D(latitude: -23.57187, longitude: -46.6444),
	 CLLocationCoordinate2D(latitude: -23.57139, longitude: -46.64429),
	 CLLocationCoordinate2D(latitude: -23.57101, longitude: -46.64474),
	 CLLocationCoordinate2D(latitude: -23.57095, longitude: -46.64469),
	 CLLocationCoordinate2D(latitude: -23.56764, longitude: -46.648979999999995),
	 CLLocationCoordinate2D(latitude: -23.56452, longitude: -46.652759999999994),
	 CLLocationCoordinate2D(latitude: -23.56445, longitude: -46.65268999999999),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.65286999999999)],
	 [
	 CLLocationCoordinate2D(latitude: -23.57231, longitude: -46.63613),
	 CLLocationCoordinate2D(latitude: -23.573, longitude: -46.636160000000004),
	 CLLocationCoordinate2D(latitude: -23.572580000000002, longitude: -46.63739),
	 CLLocationCoordinate2D(latitude: -23.57336, longitude: -46.637710000000006),
	 CLLocationCoordinate2D(latitude: -23.574350000000003, longitude: -46.637910000000005),
	 CLLocationCoordinate2D(latitude: -23.573610000000002, longitude: -46.640390000000004),
	 CLLocationCoordinate2D(latitude: -23.57306, longitude: -46.641890000000004),
	 CLLocationCoordinate2D(latitude: -23.56756, longitude: -46.64894),
	 CLLocationCoordinate2D(latitude: -23.56434, longitude: -46.65283),
	 CLLocationCoordinate2D(latitude: -23.564110000000003, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56512, longitude: -46.64607),
	 CLLocationCoordinate2D(latitude: -23.56566, longitude: -46.64647),
	 CLLocationCoordinate2D(latitude: -23.565080000000002, longitude: -46.64729),
	 CLLocationCoordinate2D(latitude: -23.56548, longitude: -46.647619999999996),
	 CLLocationCoordinate2D(latitude: -23.56512, longitude: -46.648059999999994),
	 CLLocationCoordinate2D(latitude: -23.5653, longitude: -46.64872999999999),
	 CLLocationCoordinate2D(latitude: -23.565730000000002, longitude: -46.64916999999999),
	 CLLocationCoordinate2D(latitude: -23.566070000000003, longitude: -46.65073999999999),
	 CLLocationCoordinate2D(latitude: -23.564340000000005, longitude: -46.652829999999994),
	 CLLocationCoordinate2D(latitude: -23.564110000000007, longitude: -46.65286999999999)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56884, longitude: -46.65327),
	 CLLocationCoordinate2D(latitude: -23.568730000000002, longitude: -46.65341),
	 CLLocationCoordinate2D(latitude: -23.567960000000003, longitude: -46.65264),
	 CLLocationCoordinate2D(latitude: -23.56677, longitude: -46.65407),
	 CLLocationCoordinate2D(latitude: -23.56499, longitude: -46.652339999999995),
	 CLLocationCoordinate2D(latitude: -23.564550000000003, longitude: -46.65252),
	 CLLocationCoordinate2D(latitude: -23.564580000000003, longitude: -46.65282),
	 CLLocationCoordinate2D(latitude: -23.564450000000004, longitude: -46.65269),
	 CLLocationCoordinate2D(latitude: -23.564290000000003, longitude: -46.65286),
	 CLLocationCoordinate2D(latitude: -23.564110000000003, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56884, longitude: -46.65327),
	 CLLocationCoordinate2D(latitude: -23.568730000000002, longitude: -46.65341),
	 CLLocationCoordinate2D(latitude: -23.567960000000003, longitude: -46.65264),
	 CLLocationCoordinate2D(latitude: -23.56677, longitude: -46.65407),
	 CLLocationCoordinate2D(latitude: -23.56499, longitude: -46.652339999999995),
	 CLLocationCoordinate2D(latitude: -23.564550000000003, longitude: -46.65252),
	 CLLocationCoordinate2D(latitude: -23.564580000000003, longitude: -46.65282),
	 CLLocationCoordinate2D(latitude: -23.564450000000004, longitude: -46.65269),
	 CLLocationCoordinate2D(latitude: -23.564290000000003, longitude: -46.65286),
	 CLLocationCoordinate2D(latitude: -23.564110000000003, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56884, longitude: -46.65327),
	 CLLocationCoordinate2D(latitude: -23.568730000000002, longitude: -46.65341),
	 CLLocationCoordinate2D(latitude: -23.567960000000003, longitude: -46.65264),
	 CLLocationCoordinate2D(latitude: -23.56677, longitude: -46.65407),
	 CLLocationCoordinate2D(latitude: -23.56499, longitude: -46.652339999999995),
	 CLLocationCoordinate2D(latitude: -23.564550000000003, longitude: -46.65252),
	 CLLocationCoordinate2D(latitude: -23.564580000000003, longitude: -46.65282),
	 CLLocationCoordinate2D(latitude: -23.564450000000004, longitude: -46.65269),
	 CLLocationCoordinate2D(latitude: -23.564290000000003, longitude: -46.65286),
	 CLLocationCoordinate2D(latitude: -23.564110000000003, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.57444, longitude: -46.66084),
	 CLLocationCoordinate2D(latitude: -23.57412, longitude: -46.66048),
	 CLLocationCoordinate2D(latitude: -23.57373, longitude: -46.66088),
	 CLLocationCoordinate2D(latitude: -23.57073, longitude: -46.65588),
	 CLLocationCoordinate2D(latitude: -23.56499, longitude: -46.652339999999995),
	 CLLocationCoordinate2D(latitude: -23.564580000000003, longitude: -46.65282),
	 CLLocationCoordinate2D(latitude: -23.564450000000004, longitude: -46.65269),
	 CLLocationCoordinate2D(latitude: -23.564350000000004, longitude: -46.65272),
	 CLLocationCoordinate2D(latitude: -23.564290000000003, longitude: -46.65286),
	 CLLocationCoordinate2D(latitude: -23.564110000000003, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56926, longitude: -46.67004),
	 CLLocationCoordinate2D(latitude: -23.56899, longitude: -46.66965),
	 CLLocationCoordinate2D(latitude: -23.570159999999998, longitude: -46.6684),
	 CLLocationCoordinate2D(latitude: -23.56883, longitude: -46.66524),
	 CLLocationCoordinate2D(latitude: -23.562649999999998, longitude: -46.658609999999996),
	 CLLocationCoordinate2D(latitude: -23.561989999999998, longitude: -46.65780999999999),
	 CLLocationCoordinate2D(latitude: -23.562219999999996, longitude: -46.65721999999999),
	 CLLocationCoordinate2D(latitude: -23.561939999999996, longitude: -46.65599999999999),
	 CLLocationCoordinate2D(latitude: -23.562669999999994, longitude: -46.65483999999999),
	 CLLocationCoordinate2D(latitude: -23.564109999999996, longitude: -46.65286999999999)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56542, longitude: -46.66175),
	 CLLocationCoordinate2D(latitude: -23.56262, longitude: -46.65885),
	 CLLocationCoordinate2D(latitude: -23.561989999999998, longitude: -46.65781),
	 CLLocationCoordinate2D(latitude: -23.562369999999998, longitude: -46.657379999999996),
	 CLLocationCoordinate2D(latitude: -23.562069999999995, longitude: -46.656729999999996),
	 CLLocationCoordinate2D(latitude: -23.562219999999996, longitude: -46.65636),
	 CLLocationCoordinate2D(latitude: -23.562359999999995, longitude: -46.655499999999996),
	 CLLocationCoordinate2D(latitude: -23.562729999999995, longitude: -46.6549),
	 CLLocationCoordinate2D(latitude: -23.563989999999993, longitude: -46.65291),
	 CLLocationCoordinate2D(latitude: -23.564109999999992, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.55975, longitude: -46.64827),
	 CLLocationCoordinate2D(latitude: -23.559990000000003, longitude: -46.648759999999996),
	 CLLocationCoordinate2D(latitude: -23.56031, longitude: -46.64883),
	 CLLocationCoordinate2D(latitude: -23.56071, longitude: -46.649519999999995),
	 CLLocationCoordinate2D(latitude: -23.56109, longitude: -46.64955),
	 CLLocationCoordinate2D(latitude: -23.562070000000002, longitude: -46.65079),
	 CLLocationCoordinate2D(latitude: -23.56246, longitude: -46.65006),
	 CLLocationCoordinate2D(latitude: -23.563080000000003, longitude: -46.6505),
	 CLLocationCoordinate2D(latitude: -23.56434, longitude: -46.65283),
	 CLLocationCoordinate2D(latitude: -23.564110000000003, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.57586, longitude: -46.66297),
	 CLLocationCoordinate2D(latitude: -23.57471, longitude: -46.66113),
	 CLLocationCoordinate2D(latitude: -23.57412, longitude: -46.66048),
	 CLLocationCoordinate2D(latitude: -23.57373, longitude: -46.66088),
	 CLLocationCoordinate2D(latitude: -23.57073, longitude: -46.65788),
	 CLLocationCoordinate2D(latitude: -23.56499, longitude: -46.652339999999995),
	 CLLocationCoordinate2D(latitude: -23.564580000000003, longitude: -46.65282),
	 CLLocationCoordinate2D(latitude: -23.564450000000004, longitude: -46.65269),
	 CLLocationCoordinate2D(latitude: -23.564290000000003, longitude: -46.65286),
	 CLLocationCoordinate2D(latitude: -23.564110000000003, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56559, longitude: -46.63112),
	 CLLocationCoordinate2D(latitude: -23.566850000000002, longitude: -46.660799999999995),
	 CLLocationCoordinate2D(latitude: -23.562070000000002, longitude: -46.655849999999994),
	 CLLocationCoordinate2D(latitude: -23.56236, longitude: -46.655499999999996),
	 CLLocationCoordinate2D(latitude: -23.562730000000002, longitude: -46.6549),
	 CLLocationCoordinate2D(latitude: -23.56267, longitude: -46.65484),
	 CLLocationCoordinate2D(latitude: -23.56388, longitude: -46.65338),
	 CLLocationCoordinate2D(latitude: -23.56387, longitude: -46.65304),
	 CLLocationCoordinate2D(latitude: -23.56399, longitude: -46.65291),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56461, longitude: -46.63375),
	 CLLocationCoordinate2D(latitude: -23.564, longitude: -46.63496),
	 CLLocationCoordinate2D(latitude: -23.56437, longitude: -46.63528),
	 CLLocationCoordinate2D(latitude: -23.5633, longitude: -46.63893),
	 CLLocationCoordinate2D(latitude: -23.561680000000003, longitude: -46.64443),
	 CLLocationCoordinate2D(latitude: -23.56548, longitude: -46.647619999999996),
	 CLLocationCoordinate2D(latitude: -23.5653, longitude: -46.64872999999999),
	 CLLocationCoordinate2D(latitude: -23.565730000000002, longitude: -46.64916999999999),
	 CLLocationCoordinate2D(latitude: -23.564340000000005, longitude: -46.652829999999994),
	 CLLocationCoordinate2D(latitude: -23.564110000000007, longitude: -46.65286999999999)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56363, longitude: -46.641020000000005),
	 CLLocationCoordinate2D(latitude: -23.56435, longitude: -46.64124),
	 CLLocationCoordinate2D(latitude: -23.56259, longitude: -46.64519000000001),
	 CLLocationCoordinate2D(latitude: -23.56548, longitude: -46.64762),
	 CLLocationCoordinate2D(latitude: -23.56512, longitude: -46.64806),
	 CLLocationCoordinate2D(latitude: -23.5653, longitude: -46.64873),
	 CLLocationCoordinate2D(latitude: -23.565730000000002, longitude: -46.64917),
	 CLLocationCoordinate2D(latitude: -23.566070000000003, longitude: -46.65074),
	 CLLocationCoordinate2D(latitude: -23.564340000000005, longitude: -46.65283),
	 CLLocationCoordinate2D(latitude: -23.564110000000007, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.57128, longitude: -46.65439),
	 CLLocationCoordinate2D(latitude: -23.57165, longitude: -46.65477),
	 CLLocationCoordinate2D(latitude: -23.57028, longitude: -46.65459),
	 CLLocationCoordinate2D(latitude: -23.56933, longitude: -46.65657),
	 CLLocationCoordinate2D(latitude: -23.56499, longitude: -46.65234),
	 CLLocationCoordinate2D(latitude: -23.56479, longitude: -46.65254),
	 CLLocationCoordinate2D(latitude: -23.564580000000003, longitude: -46.652820000000006),
	 CLLocationCoordinate2D(latitude: -23.564450000000004, longitude: -46.65269000000001),
	 CLLocationCoordinate2D(latitude: -23.564290000000003, longitude: -46.652860000000004),
	 CLLocationCoordinate2D(latitude: -23.564110000000003, longitude: -46.65287000000001)],
	 [
	 CLLocationCoordinate2D(latitude: -23.55976, longitude: -46.65596),
	 CLLocationCoordinate2D(latitude: -23.55903, longitude: -46.65569),
	 CLLocationCoordinate2D(latitude: -23.56021, longitude: -46.6564),
	 CLLocationCoordinate2D(latitude: -23.560930000000003, longitude: -46.65559),
	 CLLocationCoordinate2D(latitude: -23.561040000000002, longitude: -46.65545999999999),
	 CLLocationCoordinate2D(latitude: -23.56143, longitude: -46.65542999999999),
	 CLLocationCoordinate2D(latitude: -23.56388, longitude: -46.653379999999984),
	 CLLocationCoordinate2D(latitude: -23.56387, longitude: -46.65303999999998),
	 CLLocationCoordinate2D(latitude: -23.56399, longitude: -46.652909999999984),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.652869999999986)],
	 [
	 CLLocationCoordinate2D(latitude: -23.562070000000002, longitude: -46.65585),
	 CLLocationCoordinate2D(latitude: -23.56734, longitude: -46.66131),
	 CLLocationCoordinate2D(latitude: -23.56236, longitude: -46.6555),
	 CLLocationCoordinate2D(latitude: -23.56229, longitude: -46.65543),
	 CLLocationCoordinate2D(latitude: -23.562730000000002, longitude: -46.654900000000005),
	 CLLocationCoordinate2D(latitude: -23.56267, longitude: -46.65484000000001),
	 CLLocationCoordinate2D(latitude: -23.56388, longitude: -46.653380000000006),
	 CLLocationCoordinate2D(latitude: -23.56387, longitude: -46.653040000000004),
	 CLLocationCoordinate2D(latitude: -23.56399, longitude: -46.652910000000006),
	 CLLocationCoordinate2D(latitude: -23.56411, longitude: -46.65287000000001)],
	 [
	 CLLocationCoordinate2D(latitude: -23.562070000000002, longitude: -46.655849999999994),
	 CLLocationCoordinate2D(latitude: -23.56998, longitude: -46.66403),
	 CLLocationCoordinate2D(latitude: -23.56236, longitude: -46.655499999999996),
	 CLLocationCoordinate2D(latitude: -23.56229, longitude: -46.655429999999996),
	 CLLocationCoordinate2D(latitude: -23.562730000000002, longitude: -46.6549),
	 CLLocationCoordinate2D(latitude: -23.56267, longitude: -46.65484),
	 CLLocationCoordinate2D(latitude: -23.56367, longitude: -46.65384),
	 CLLocationCoordinate2D(latitude: -23.56388, longitude: -46.65338),
	 CLLocationCoordinate2D(latitude: -23.56387, longitude: -46.65304),
	 CLLocationCoordinate2D(latitude: -23.564110000000003, longitude: -46.65287)],
	 [
	 CLLocationCoordinate2D(latitude: -23.56781, longitude: -46.65665),
	 CLLocationCoordinate2D(latitude: -23.56729, longitude: -46.65724),
	 CLLocationCoordinate2D(latitude: -23.56429, longitude: -46.65524),
	 CLLocationCoordinate2D(latitude: -23.56375, longitude: -46.65382),
	 CLLocationCoordinate2D(latitude: -23.564059999999998, longitude: -46.65345000000001),
	 CLLocationCoordinate2D(latitude: -23.56393, longitude: -46.65332000000001),
	 CLLocationCoordinate2D(latitude: -23.563879999999997, longitude: -46.653380000000006),
	 CLLocationCoordinate2D(latitude: -23.563869999999998, longitude: -46.653040000000004),
	 CLLocationCoordinate2D(latitude: -23.563989999999997, longitude: -46.652910000000006),
	 CLLocationCoordinate2D(latitude: -23.564109999999996, longitude: -46.65287000000001)]]
	
	private var exists: Bool = false
	
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
		
		Auth.auth().signInAnonymously(completion: { (user, error) in
			self.observePlayers()
		})
	}
	
	deinit {
		if let refHandle = playerRefHandle {
			playerRef.removeObserver(withHandle: refHandle)
		}
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
		
		playerMarkerView.layer.borderColor = UIColor.white.cgColor
		playerMarkerView.layer.borderWidth = 1.5
		
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
	
	func addPlayerMarkers(id: String, playerData: Dictionary<String, AnyObject>, eventType: String) {
		if let name = playerData["name"] as? String, name.count > 0 {
			let player = Player([
				"id": playerData["id"] ?? 0,
				"name": playerData["name"] ?? "",
				"icon": playerData["icon"] ?? "",
				"clickCount": playerData["clickCount"] ?? ""
				] as [String : Any])
			
			let playerMarker = GMSMarker()
			
			playerMarker.iconView = playerMarkerView
			playerMarker.map = mapView
			playerMarker.appearAnimation = GMSMarkerAnimation.pop
			
			playerMarkers.append(playerMarker)
			
			CATransaction.begin()
			CATransaction.setAnimationDuration(0.5)
			playerMarkers[player.id].position = playersCoordinates[player.id][0]
//			playerMarkers[player.id].rotation = (lastLocation?.course)!
			CATransaction.commit()
		
			self.players.append(player)
		} else {
			print("Error! Could not decode channel data")
		}
	}
	
    func updatePlayerMarkers(id: String, playerData: Dictionary<String, AnyObject>, eventType: String) {
		if let name = playerData["name"] as? String, name.count > 0 {
			let player = Player([
				"id": playerData["id"] ?? 0,
				"name": playerData["name"] ?? "",
				"icon": playerData["icon"] ?? "",
				"clickCount": playerData["clickCount"] ?? 0
				] as [String : Any])
			
			if playersCoordinates.count > player.id {
				CATransaction.begin()
				CATransaction.setAnimationDuration(0.5)
				playerMarkers[player.id].position = playersCoordinates[player.id][player.clickCount]
				CATransaction.commit()
			} else {
				// Player won
			}
		} else {
			print("Error! Could not decode channel data")
		}
	}
	
    private func observePlayers() {
		playerRefHandle = playerRef.observe(.childAdded, with: { (snapshot) -> Void in
			let playerData = snapshot.value as! Dictionary<String, AnyObject>
			
			self.addPlayerMarkers(id: snapshot.key, playerData: playerData, eventType: "added")
		})
		
		playerRefHandle = playerRef.observe(.childRemoved, with: { (snapshot) -> Void in
//			let playerData = snapshot.value as! Dictionary<String, AnyObject>
			
//			self.updateMapMarkers(id: snapshot.key, playerData: playerData, eventType: "removed")
		})
		
		playerRefHandle = playerRef.observe(.childChanged, with: { (snapshot) -> Void in
			let playerData = snapshot.value as! Dictionary<String, AnyObject>
			
			self.updatePlayerMarkers(id: snapshot.key, playerData: playerData, eventType: "changed")
		})
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
	
    func directionsSearch(coordinates: CLLocationCoordinate2D) {
    	print(coordinates)
    	print(playersCoordinates.count)
		
		let waypoints = [
			Waypoint(coordinate: coordinates, name: "Player"),
			Waypoint(coordinate: CLLocationCoordinate2D(latitude: -23.5641095, longitude: -46.6524099), name: "FIAP"),
		]
		let options = RouteOptions(waypoints: waypoints, profileIdentifier: .walking)
		options.includesSteps = true

		let task = directions.calculate(options) { (waypoints, routes, error) in
			guard error == nil else {
				print("Error calculating directions: \(error!)")
				return
			}

			if let route = routes?.first, let leg = route.legs.first, route.coordinateCount > 0 {
				let distanceFormatter = LengthFormatter()
				let formattedDistance = distanceFormatter.string(fromMeters: route.distance)

				let travelTimeFormatter = DateComponentsFormatter()
				travelTimeFormatter.unitsStyle = .short
				let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
				
				print(route.coordinates)
				print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")

				for step in leg.steps {
//					print("\(step.instructions)")
					let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
//					print("— \(formattedDistance) —")
				}
			}
		}
		
		task.resume()
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
		directionsSearch(coordinates: coordinate)
		
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
//			mapView.animate(to: GMSCameraPosition(target: location.coordinate, zoom: 16, bearing: 0, viewingAngle: 0))
			mapView.animate(to: GMSCameraPosition(target: CLLocationCoordinate2D(latitude: -23.5641095, longitude: -46.6524099), zoom: 15, bearing: 0, viewingAngle: 0))
			
			CATransaction.begin()
			CATransaction.setAnimationDuration(0.5)
			currentLocationMarker.position = CLLocationCoordinate2D(latitude: -23.5641095, longitude: -46.6524099)
			currentLocationMarker.rotation = location.course
			CATransaction.commit()
			
//			parkingMarker.position = CLLocationCoordinate2DMake(location.coordinate.latitude + 0.001, location.coordinate.longitude - 0.001)
//			parkingMarker2.position = CLLocationCoordinate2DMake(location.coordinate.latitude - 0.001, location.coordinate.longitude + 0.002)
//			parkingMarker3.position = CLLocationCoordinate2DMake(location.coordinate.latitude - 0.003, location.coordinate.longitude + 0.002)
//			parkingMarker4.position = CLLocationCoordinate2DMake(location.coordinate.latitude - 0.0015, location.coordinate.longitude - 0.002)
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
		
		
		
		
		
		
		// Player Directions (Delete)
		
		directionsSearch(coordinates: locations[indexPath.row].location)
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
