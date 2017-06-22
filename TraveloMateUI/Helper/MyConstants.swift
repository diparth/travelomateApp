//
//  Constants.swift
//  DemoNavigation
//
//  Created by Diparth Patel on 3/28/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import Foundation


//Dhruv APN: net.dhruvpatel.travelomate


//Base URL for navigation = http://35.185.102.127:8080/travelomate/parseVoice?speech=navigate%20me%20to%20nearest%20taco%20bell&lat=40.56927012&lng=-74.54811841
//Base URL for weather from OpenWeather = http://api.openweathermap.org/data/2.5/weather?lat=\(Location.sharedInstance.latitude!)&lon=\(Location.sharedInstance.longitude!)&appid=42a1771a0b787bf12e734ada0cfc80cb


let GMS_API_KEY = "AIzaSyBbyuHBfCtVo18k885B5yVdX_XKgGT2yUg"
let GMS_PLACE_KEY = "AIzaSyBbyuHBfCtVo18k885B5yVdX_XKgGT2yUg"

let BASE_URL = "http://35.185.102.127:8080/travelomate/parseVoice?speech="
let LAT_URL = "&lat="
let LONG_URL = "&lng="

let NAVIGATION_URL = "http://35.185.102.127:8080/travelomate/parseVoice?speech=navigate%20me%20to%20nearest%20taco%20bell&lat=40.56927012&lng=-74.54811841"
let PLACE_NAV_URL = "https://maps.googleapis.com/maps/api/directions/json?origin=40.56927012,-74.548118&destination=40.68234,-74.67234&key=AIzaSyBbyuHBfCtVo18k885B5yVdX_XKgGT2yUg"




let CURRENT_WEATHER_URL = ""


//Alamofire

typealias DownloadComplete = () -> ()



//Spotify

let kSPT_CLIENT_ID = "731c6c19324c47f785f482dc01c011b5"
let kSPT_CLIENT_SECRET = "71578effd89248aca8e3898944dab38c"
let kSPT_CALLBACK_URL = "com.travelomate://spotify-auth-callback"
let kSPT_SESSION_USER_KEY = "spotifySessionKey"



//Sinch calling APIs

let kSINCH_HOST = "sandbox.sinch.com"
let kSINCH_KEY = "8b6fdc08-82ea-4c35-bbd0-1bcddc202c81"
let kSINCH_SECRET = "exPbxJHacEyxvAEx0H+Ltw=="




