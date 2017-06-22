//
//  Navigation.swift
//  DemoNavigation
//
//  Created by Diparth Patel on 3/28/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit
import CoreLocation

public class Navigation {

    var polyline = [Polyline]()
    var htmlInsts = [String]()
    var destAddress: String!
    var destName: String!
    var startLoc: CLLocation!
    var endLoc: CLLocation!
    var startLocations = [CLLocation]()
    var endLocations = [CLLocation]()
    //Guides -> Maneuver
    var guides = [String]()
    

    
    func getPolylinesWith(polylineEncodedString: String){
    
        self.polyline.append(Polyline.init(encodedPolyline: polylineEncodedString))
        
    }
    
    init(navigationDict: Dictionary <String, Any>) {
    
        if let directions = navigationDict["directions"] as? Dictionary<String, Any> {
            
            if let data = directions["data"] as? Dictionary<String, Any> {
                
                if let steps = data["steps"] as? [Dictionary<String, Any>] {
                    
                    for step in steps {
                        if let polyline = step["polyline"] as? Dictionary<String, Any>{
                            if let points = polyline["points"] as? String {
                                
                                self.getPolylinesWith(polylineEncodedString: points)
                
                            }
                        }
                        if let htmlInst = step["html_instructions"] as? String {
                            self.htmlInsts.append(self.filterAllUnicodeFrom(string: htmlInst))
                            //print(self.filterAllUnicodeFrom(string: htmlInst))
                        }
                        if let startLoc = step["start_location"] as? Dictionary<String, Any> {
                            self.setStartLocationFor(dict: startLoc)
                        }
                        if let endLoc = step["end_location"] as? Dictionary<String, Any> {
                            self.setEndLocationFor(dict: endLoc)
                        }
                        if let guide = step["maneuver"] as? String {
                            self.guides.append(self.removeDashFrom(string: guide))
                            //print(self.removeDashFrom(string: guide))
                        }else {
                            self.guides.append("")
                        }
                    }
                }
                
                if let destAdd = data["end_address"] as? String {
                    self.destAddress = destAdd
                }
                if let startLoc = data["start_location"] as? Dictionary<String, Any> {
                    var lng = Double()
                    var lat = Double()
                    if let long = startLoc["lng"] as? Double {
                        lng = long
                    }
                    if let latt = startLoc["lat"] as? Double {
                        lat = latt
                    }
                    self.startLoc = CLLocation.init(latitude: lat, longitude: lng)
                }
                if let startLoc = data["end_location"] as? Dictionary<String, Any> {
                    var lng = Double()
                    var lat = Double()
                    if let long = startLoc["lng"] as? Double {
                        lng = long
                    }
                    if let latt = startLoc["lat"] as? Double {
                        lat = latt
                    }
                    self.endLoc = CLLocation.init(latitude: lat, longitude: lng)
                }
            }
            
        }
        
        if let nameDict = navigationDict["data"] as? [Dictionary<String, Any>] {
            if let name = nameDict[0]["name"] as? String {
                self.destName = name
            }
        }
    }
    
    
    
    //Data->Steps
    init(myData: Dictionary<String, Any>, name: String) {
        
        self.destName = name
        
        if let steps = myData["steps"] as? [Dictionary<String, Any>] {
            
            for step in steps {
                if let polyline = step["polyline"] as? Dictionary<String, Any>{
                    if let points = polyline["points"] as? String {
                        
                        self.getPolylinesWith(polylineEncodedString: points)
                        
                    }
                    
                }
                if let htmlInst = step["html_instructions"] as? String {
                    self.htmlInsts.append(self.filterAllUnicodeFrom(string: htmlInst))
                    //print(self.filterAllUnicodeFrom(string: htmlInst))
                }
                if let startLoc = step["start_location"] as? Dictionary<String, Any> {
                    self.setStartLocationFor(dict: startLoc)
                }
                if let endLoc = step["end_location"] as? Dictionary<String, Any> {
                    self.setEndLocationFor(dict: endLoc)
                }
                if let guide = step["maneuver"] as? String {
                    self.guides.append(self.removeDashFrom(string: guide))
                    //print(self.removeDashFrom(string: guide))
                }else {
                    self.guides.append("")
                }
            }
            
            if let destAdd = myData["end_address"] as? String {
                self.destAddress = destAdd
            }
            if let startLoc = myData["start_location"] as? Dictionary<String, Any> {
                var lng = Double()
                var lat = Double()
                if let long = startLoc["lng"] as? Double {
                    lng = long
                }
                if let latt = startLoc["lat"] as? Double {
                    lat = latt
                }
                self.startLoc = CLLocation.init(latitude: lat, longitude: lng)
            }
            if let startLoc = myData["end_location"] as? Dictionary<String, Any> {
                var lng = Double()
                var lat = Double()
                if let long = startLoc["lng"] as? Double {
                    lng = long
                }
                if let latt = startLoc["lat"] as? Double {
                    lat = latt
                }
                self.endLoc = CLLocation.init(latitude: lat, longitude: lng)
            }
            
        }
    }
    
    
    //Init endloc and destname
    init(endloc: CLLocation, destName: String) {
        self.endLoc = endloc
        self.destName = destName
        self.destAddress = nil
        self.startLoc = nil
    }
    
    
    
    func filterAllUnicodeFrom(string: String) -> String {
        var myStr = string.replacingOccurrences(of: "</b>", with: "")
        myStr = myStr.replacingOccurrences(of: "<b>", with: "")
        myStr = myStr.replacingOccurrences(of: "<div style=\"font-size:0.9em\">", with: " ")
        myStr = myStr.replacingOccurrences(of: "</div>", with: "")
        myStr = myStr.replacingOccurrences(of: "/", with: " ")
        return myStr
    }

    
    
    func removeDashFrom(string: String) -> String {
        let finalStr = string.replacingOccurrences(of: "-", with: " ").capitalized
        
        return finalStr
    }
    
    func setStartLocationFor(dict: Dictionary<String, Any>) {
        var coord = CLLocationCoordinate2D()
        if let lat = dict["lat"] as? Double {
            coord.latitude = lat
        }
        if let long = dict["lng"] as? Double {
            coord.longitude = long
        }
        self.startLocations.append(CLLocation.init(latitude: coord.latitude, longitude: coord.longitude))
    }
    
    
    func setEndLocationFor(dict: Dictionary<String, Any>) {
        var coord = CLLocationCoordinate2D()
        if let lat = dict["lat"] as? Double {
            coord.latitude = lat
        }
        if let long = dict["lng"] as? Double {
            coord.longitude = long
        }
        self.endLocations.append(CLLocation.init(latitude: coord.latitude, longitude: coord.longitude))
    }
    
    
}







