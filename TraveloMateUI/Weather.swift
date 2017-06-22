//
//  Weather.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/4/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//


//JSON Response
//"condition": "Mist",
//"weather_type_description": "mist",
//"temperature": 15,
//"weather_wind_degree": 90,
//"weather_temp_min": 9,
//"weather_sunset": 1491348428,
//"weather_wind_speed": 2.6,
//"weather_temp_max": 24,
//"weather_sunrise": 1491302110


import UIKit
import Foundation


public class Weather {

    var condition: String!
    var weatherType: String!
    var temperature: Int!
    var tempMin: Int!
    var tempMax: Int!
    var sunsetTime: Double!
    var sunriseTime: Double!
    var windSpeed: Double!
    var windDegree: Int!
    
    init(dataDict: Dictionary<String, Any>) {
    
        if let cond = dataDict["condition"] as? String {
            self.condition = cond
        }
        if let type = dataDict["weather_type_description"] as? String {
            self.weatherType = type
        }
        if let temp = dataDict["temperature"] as? Int {
            self.temperature = temp
        }
        if let tmin = dataDict["weather_temp_min"] as? Int {
            self.tempMin = tmin
        }
        if let tmax = dataDict["weather_temp_max"] as? Int {
            self.tempMax = tmax
        }
        if let sunset = dataDict["weather_sunset"] as? Double {
            self.sunsetTime = sunset
        }
        if let sunrise = dataDict["weather_sunrise"] as? Double {
            self.sunriseTime = sunrise
        }
        if let wspeed = dataDict["weather_wind_speed"] as? Double {
            self.windSpeed = wspeed
        }
    }
    
    
}




