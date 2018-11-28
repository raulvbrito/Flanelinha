//
//  Location.swift
//  Flanelinha
//
//  Created by Raul Brito on 28/11/18.
//  Copyright © 2018 Raul Brito. All rights reserved.
//

import Foundation
import Tailor
import CoreLocation

struct Location: Mappable {
	
    var Title: String!
    var Subtitle: String!
    var Genre: String!
    var Latitude: Double!
    var Longitude: Double!
    var Location: CLLocationCoordinate2D!
	
    init(_ map: [String : Any]) {
        Title <- map.property("Title")
        Subtitle <- map.property("Subtitle")
        Genre <- map.property("Genre")
        Latitude <- map.property("Latitude")
        Longitude <- map.property("Longitude")
        Location <- map.property("Location")
    }
}
