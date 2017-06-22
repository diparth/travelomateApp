//
//  Place.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/3/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

//JSON Response for single place obj
//"duration":"7 mins",
//"address":"288 Lincoln Boulevard, Middlesex",
//"distance":"2.5 mi",
//"name":"Soul Food Palace",
//"rating":2.5,
//"location":{"lng":-74.50628329999999,"lat":40.5641076},
//"google_place_id":"ChIJVQpTAUy_w4kRkq1kyqzYGrE"

public class Place {
    
    var duration: String!
    var distance: String!
    var address: String!
    var name: String!
    var rating: Double!
    var location: CLLocation!
    var googlePlaceID: String!
    
    func setLocation(locObj: Dictionary<String, Double>) {
        let tempLoc = CLLocation.init(latitude: locObj["lat"]!, longitude: locObj["lng"]!)
        self.location = tempLoc
    }
    
    init(placeDict: Dictionary<String, Any>) {
        if let duration = placeDict["duration"] as? String {
            self.duration = duration
        }
        if let address = placeDict["address"] as? String {
            self.address = address
        }
        if let distance = placeDict["distance"] as? String {
            self.distance = distance
        }
        if let name = placeDict["name"] as? String {
            self.name = name
        }
        if let rate = placeDict["rating"] as? Double {
            self.rating = rate
        }
        if let googleplaceid = placeDict["google_place_id"] as? String {
            self.googlePlaceID = googleplaceid
        }
        if let loc = placeDict["location"] as? Dictionary<String, Double> {
            self.setLocation(locObj: loc)
        }
    }
    
}
