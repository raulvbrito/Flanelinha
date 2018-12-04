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
	
    var title: String!
    var subtitle: String!
    var genre: String!
    var isAffiliate: Bool!
    var latitude: Double!
    var longitude: Double!
    var location: CLLocationCoordinate2D!
	
    init(_ map: [String : Any]) {
        title <- map.property("title")
        subtitle <- map.property("subtitle")
        genre <- map.property("genre")
        isAffiliate <- map.property("isAffiliate")
        latitude <- map.property("latitude")
        longitude <- map.property("longitude")
        location <- map.property("location")
    }
}
