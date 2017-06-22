
//
//  ViewController.swift
//  DemoNavigation
//
//  Created by Diparth Patel on 3/28/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import GoogleSignIn
import AVFoundation
import GoogleMaps
import FirebaseDatabase

var userEmailID: String!
var userFname: String!
var userLname: String!
var userPicUrl: URL!
var userSqlID: Int!
var tripSqlID: Int!


var shareFlag: Bool!

class NavigationVC: UIViewController,  CLLocationManagerDelegate, GIDSignInDelegate, GIDSignInUIDelegate, FIRInviteDelegate {

    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    
    
    var navigationObj : Navigation!
    var newNavObj: Navigation!
    var locationManager = CLLocationManager()
    var currentLoc : CLLocation!
    var mapView : GMSMapView!
    let marker = GMSMarker()
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    
    var camera: GMSCameraPosition!
    var locPoints = [CLLocation]()
    var routeFlag = true
    var navUrl: URL!
    
    var observRef: FIRDatabaseReference!
    var observRefHandled: FIRDatabaseHandle!
    
    var speechSynthesizer = AVSpeechSynthesizer()
    var speechUtterance = AVSpeechUtterance()
    
    var totalUserCount: Int!
    
    var pointCount: Int!
    
    var userToMarker = [String: GMSMarker]()
    
    //var isNavAvail = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.shareButton.layer.cornerRadius = self.shareButton.frame.height/2
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        locationManager.delegate = self
        
        self.pointCount = 0
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        
        self.camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: 18.0)
        
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
    
        //self.myView = mapView
        self.myView.addSubview(mapView)
        
        mapView.isHidden = true
        
        do{
            if let fileUrl = Bundle.main.url(forResource: "mapstyle", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle.init(contentsOfFileURL: fileUrl)
            }else{
                print("Unable to find JSON")
            }
        }catch let error{
            print("Error in loading map style: \(error)")
        }
        
        if(self.navigationObj === DashboardVC.tripNavObj) {
            self.closeBarButton.isEnabled = true
        }else {
            self.closeBarButton.isEnabled = false
            
        }
        
        //Share will be hide if trip is on
//        if (DashboardVC.tripNavObj != nil && tripSqlID != nil) {
//            self.shareButton.isHidden = true
//            self.shareButton.isEnabled = false
//        }
        
     
        if tripUsers.count > 0 {
        
            if DashboardVC.tripNavObj != nil && tripSqlID != nil{
            //Fetch other user's location here!
               // observRefHandled = observRef.child("trips/\(tripSqlID!)/").observe(.value, with: { (snapshot) in
                  //  if let dataDict
                //})
            }
        }
        
//        if self.navigationObj != nil{
//            self.drawPolylinesWithNavigation(navigation: self.navigationObj)
//        }
        
        self.processJSONData {
            print("inside process json data")
        }
        
    }
    
    
    func fetchTripUsers() {
    
        if(tripSqlID != nil && userSqlID != nil) {
            do {
                // open a new connection
                try con.open("35.185.34.14", user: "diparth", passwd: "diparthpatel309")
                try con.use(db_name)
                if userEmailID != nil {
                    
                    //var selectSmt = try con.prepare("SELECT * FROM user WHERE _id<>\"\(userSqlID!)\"")
                    let selectSmt = try con.prepare("select distinct(u._id),u.first_name,u.last_name from user u, trips_user_mapping tm where tm.trip_id = \(tripSqlID!) and tm.user_id <> \(userSqlID!) and u._id = tm.user_id")
                    let result = try selectSmt.query([])
                    var rows = try result.readAllRows()
                    if (rows?.count)! > 0 {
                        tripUsers = [Users]()
                        for row in (rows?[0])! {
                            let id = row["_id"] as! Int
                            let fname = row["first_name"] as! String
                            let lname = row["last_name"] as! String
                            let email = row["email"] as! String
                            let picStr = row["pro_pic"] as! String
                            tripUsers.append(Users.init(id: id, fName: fname, lName: lname, email: email, picStr: picStr))
                        }
                    }
                    
                }
                try con.close()
            }catch(let e) {
                print("Error: \(e)")
            }
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
//        if (DashboardVC.tripNavObj != nil && tripSqlID != nil) {
//            self.shareButton.isHidden = true
//            self.shareButton.isEnabled = false
//        }
        
        if(isUserAllowedToUpdateLoc == true && tripSqlID != nil && userSqlID != nil) {
            self.fetchOtherUsersLoc()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        
        self.currentLoc = location
        print("Location: \(location)")
        
        
//        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,longitude: location.coordinate.longitude,zoom: 17.0)
        
        camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 19.0, bearing: (bearingAngle), viewingAngle: 75)
        
        //Start turn-by-turn navigation.
        if (self.navigationObj != nil && self.newNavObj != nil) {
            if pointCount < self.newNavObj.polyline.count {
                if (self.currentLoc.distance(from: self.newNavObj.startLocations[pointCount]) < 30) {
                    
                    print("\(pointCount): \(self.navBarItem.title = self.newNavObj.htmlInsts[pointCount])")
                    print("Distance: \(self.currentLoc.distance(from: self.newNavObj.startLocations[pointCount]))")
                
                    self.navBarItem.title = self.newNavObj.guides[pointCount]
                    self.speakNavigationInst(instruction: self.newNavObj.htmlInsts[pointCount])
                    pointCount = pointCount + 1
                }else {
                    if pointCount == 0 && routeFlag {
                        self.routeFlag = false
                        self.speakNavigationInst(instruction: "Please, proceed towards highlighted route.")
                    }
                }
//                if (self.currentLoc.distance(from: self.navigationObj.startLocations[pointCount]) > 30) {
//                    self.navBarItem.title = ""
//                }
            }
//            else {
//                pointCount = 0
//            }
            
            //check if navigationObj has more than 0 endLocations
            if(self.newNavObj != nil && self.navigationObj != nil && self.newNavObj.endLocations.count > 0) {
                if (self.currentLoc.distance(from: self.newNavObj.endLocations.last!) < 30) {
                    pointCount = 0
                    self.speakNavigationInst(instruction: "You have arrived at your destination.")
                    self.navigationObj = nil
                    self.newNavObj = nil
                    DashboardVC.navObj = nil
                    self.routeFlag = true
                    pointCount = 0
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    })
                    
                }
            }
            
            //Update user location to firebase
            if(isUserAllowedToUpdateLoc == true && tripSqlID != nil && userSqlID != nil) {
                self.updateUserLocTo(location: self.currentLoc!)
            }
            
            
            if(isUserAllowedToUpdateLoc == true && tripSqlID != nil && userSqlID != nil) {
                self.fetchOtherUsersLoc()
            }
            
            
            
        }
        
//        let position = location.coordinate
//        let marker = GMSMarker.init(position: position)
//        marker.icon = UIImage.init(named: "navmarker.png")
//        marker.groundAnchor = CGPoint.init(x: 0.5, y: 0.5)
//        marker.map = mapView
        
        mapView.isBuildingsEnabled = false
        mapView.isIndoorEnabled = false
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
    }
    
    
    func fetchOtherUsersLoc() {
        
        if(tripUsers.count > 0) {
            firebaseDataReference = FIRDatabase.database().reference(withPath: "trips/\(tripSqlID!)/currentUserLocation/")
            
            let _ = firebaseDataReference.observe(.value, with: { (snap) in
                if let dict = snap.value as? Dictionary<String, Any> {
                    let keys = Array(dict.keys)
                    for key in keys {
                        if(key != "user:3") {
                            if(self.userToMarker[key] != nil) {
                                if let user = dict[key] as? Dictionary<String, Any> {
                                    let lat = user["x"] as? Double
                                    let long = user["y"] as? Double
                                    self.userToMarker[key]?.position = CLLocationCoordinate2D.init(latitude: lat!, longitude: long!)
                                }
                            }else {
                                if let user = dict[key] as? Dictionary<String, Any> {
                                    let lat = user["x"] as? Double
                                    let long = user["y"] as? Double
                                    let uname = user["userName"] as? String
                                    var proPicUrl = user["userProPic"] as? String
                                    proPicUrl = self.picUrlToSize(str: proPicUrl!)
                                    let marker = GMSMarker.init(position: CLLocationCoordinate2D.init(latitude: lat!, longitude: long!))
                                    marker.title = uname!
                                    
                                    if(proPicUrl != "" && (proPicUrl?.characters.count)! > 5) {
                                        let imgView = UIImageView.init(image: UIImage.init(data: try! Data.init(contentsOf: URL.init(string: proPicUrl!)!)))
                                        imgView.layer.cornerRadius = imgView.frame.width/2
                                        marker.iconView = imgView
                                    }
                                    
                                    self.userToMarker[key] = marker
                                    self.userToMarker[key]?.map = self.mapView
                                }
                            }
                        }
                    }
                }
            })
        }
        
    }
    
    
    
    func picUrlToSize(str: String) -> String {
        
        if(str != "") {
            var strings = str.components(separatedBy: "/")
            strings[7] = "s34"
            let finalStr = "\(strings[0])/\(strings[1])/\(strings[2])/\(strings[3])/\(strings[4])/\(strings[5])/\(strings[6])/\(strings[7])/\(strings[8])"
            return finalStr
        }
        
        return ""
    }
    
    
    
    func processJSONData(completed: @escaping DownloadComplete) {
//        let urlstr = "https://maps.googleapis.com/maps/api/directions/json?origin=\(DashboardVC.currentLoc.coordinate.latitude),\(DashboardVC.currentLoc.coordinate.longitude)&destination=\(midPointLocation.coordinate.latitude),\(midPointLocation.coordinate.longitude)&key=\(GMS_PLACE_KEY)"
        let urlstr = "https://maps.googleapis.com/maps/api/directions/json?origin=\(DashboardVC.currentLoc.coordinate.latitude),\(DashboardVC.currentLoc.coordinate.longitude)&destination=\(self.navigationObj.endLoc.coordinate.latitude),\(self.navigationObj.endLoc.coordinate.longitude)&key=\(GMS_PLACE_KEY)"
        self.navUrl = URL.init(string: urlstr)
        let url = self.navUrl!
        print("\(url)")
        
        Alamofire.request(url).responseJSON { (response) in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, Any> {
                if let routes = dict["routes"] as? [Dictionary<String, Any>] {
                    if let legs = routes[0]["legs"] as? [Dictionary<String, Any>] {
                        self.newNavObj = Navigation.init(myData: legs[0], name: self.navigationObj.destName!)
                        if self.newNavObj != nil {
                            self.drawPolylinesWithNavigation(navigation: self.newNavObj!)
                            if(DashboardVC.tripNavObj != nil) {
                                if(self.newNavObj.endLoc.coordinate.latitude == DashboardVC.tripNavObj.endLoc.coordinate.latitude && self.newNavObj.endLoc.coordinate.longitude == DashboardVC.tripNavObj.endLoc.coordinate.longitude) {
                                    DashboardVC.tripNavObj = self.newNavObj
                                }
                            }
                        }
                    }
                }
            }
            completed()
        }
        
    }
    
    
    
    func navigateToMidpoint() {
        
        if self.newNavObj != nil {
            for vc in (self.navigationController?.viewControllers)! {
                if(vc.isKind(of: NavigationVC.self)) {
                    let temp = vc as! NavigationVC
                    temp.navigationObj = self.newNavObj!
                    self.navigationController?.popToViewController(temp, animated: true)
                }
            }
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        if(newHeading.headingAccuracy < 0) {
            print("Heading accuracy < 0")
            return
        }
        
        let heading = newHeading.magneticHeading
        bearingAngle =  heading
        CATransaction.begin()
        CATransaction.setValue(NSNumber.init(value: 0.5), forKey: kCATransactionAnimationDuration)
        //let headingDegree = (heading*M_PI/180)
        self.mapView.animate(toBearing: (heading))
        CATransaction.commit()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    func speakNavigationInst(instruction: String) {
        
        speechUtterance = AVSpeechUtterance(string: instruction)
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speechUtterance.pitchMultiplier = 1
        speechUtterance.volume = 1
        speechSynthesizer.speak(speechUtterance)
    }
    
    
    @IBAction func cancelTripPressed(_ sender: Any) {
        
        pointCount = 0
        bearingAngle = 0
        DashboardVC.tripNavObj = nil
        tripSqlID = nil
        myPreferences.tripSqlID = nil
        userDefaults.set(false, forKey: "isPreferencesAvail")
        tripUsers = [Users]()
        _ = self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    
    
    
    func printNavDetails() {
    
        print(self.navigationObj.polyline.count)
    }
    
    
    func drawPolylinesWithNavigation(navigation: Navigation) {
    
        let path = GMSMutablePath()

        for polyline in navigation.polyline{
            for cood in polyline.coordinates!{
                path.add(cood)
                
                self.locPoints.append(CLLocation.init(latitude: cood.latitude, longitude: cood.longitude))
                
                //print("Point is: \(cood)")
            }
        }

        let line = GMSPolyline.init(path: path)
        line.strokeWidth = 10.0
        line.strokeColor = UIColor.init(red: 255/255, green: 102/255, blue: 102/255, alpha: 1.0)
        line.geodesic = true
        line.map = mapView
        
    }
    
    func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    
    func radiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
    
    func getBearingBetweenTwoPoints(point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(degrees: point1.coordinate.latitude)
        let lon1 = degreesToRadians(degrees: point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.coordinate.latitude)
        let lon2 = degreesToRadians(degrees: point2.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radians: radiansBearing)
    }
    
    
    //MARK: Shareing features
    
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        
//        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance().signIn()
        myPreferences.userFname = userFname!
        myPreferences.userLname = userLname!
        myPreferences.userEmailID = userEmailID!
        myPreferences.userPicUrl = userPicUrl!
        
        print("Name:\(userFname!) \(userLname!)")
        
        if(tripSqlID != nil && userSqlID != nil) {
            self.processInvite()
        }else {
            processUserWith(id: userEmailID!)
        }
        
        
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("Error in google signin: \(error)")
        }else {
            if let _ = user.profile.name {
                userFname = user.profile.givenName!
                userLname = user.profile.familyName!
                userEmailID = user.profile.email!
                userPicUrl = user.profile.imageURL(withDimension: UInt.min)!
                
                myPreferences.userFname = userFname!
                myPreferences.userLname = userLname!
                myPreferences.userEmailID = userEmailID!
                myPreferences.userPicUrl = userPicUrl!
                
                print("Name:\(userFname!) \(userLname!)")
                processUserWith(id: userEmailID!)
            }else {
                print("------->Name is not available.")
            }
        }
        guard let authentication = user.authentication else {
            return
        }
        
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        print("----->Credentials are: \(credential)")
        
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            // ...
            if let error = error {
                print("Error occured: \(error)")
                return
            }
            
        }
    }
    
    func processUserWith(id: String) {
        
        do{
            // open a new connection
            try con.open("35.185.34.14", user: "diparth", passwd: "diparthpatel309")
            try con.use(db_name)
            
            if userEmailID != nil {
                let selectSmt = try con.prepare("SELECT * FROM user WHERE email=\"\(id)\"")
                
                var result = try selectSmt.query([])
                var rows = try result.readAllRows()
                
                // Check user or add it
                if (rows?.count)! > 0 {
                    let userSqlID = rows?[0][0]["_id"]
                    print("=========>> Name: \(userSqlID!)")
                }else {
                    let insertSmt = try con.prepare("INSERT INTO user(first_name, last_name, email, pro_pic) VALUES(\"\(userFname!)\",\"\(userLname!)\",\"\(userEmailID!)\",\"\(userPicUrl!)\")")
                    try insertSmt.exec([])
                 }
                
                // Grab user's SQL ID
                result = try selectSmt.query([])
                rows = try result.readAllRows()
                
                if (rows?.count)! > 0 {
                    let sqlID = rows?[0][0]["_id"]
                    userSqlID = sqlID as? Int
                    print("=========>> Sql ID: \(userSqlID!)")
                }
                
                //Add Trip to SQL table
                if userSqlID != nil {
                    if self.navigationObj != nil {
                        do {
                            
                            let insertSmt = try con.prepare("INSERT INTO trips(start_lat, start_lng, end_lat, end_lng, dest_address, initiator_id) VALUES(\"\(self.navigationObj.startLoc.coordinate.latitude)\",\"\(self.navigationObj.startLoc.coordinate.longitude)\",\"\(self.navigationObj.endLoc.coordinate.latitude)\",\"\(self.navigationObj.endLoc.coordinate.longitude)\",\"\(self.navigationObj.destAddress!)\",\(userSqlID!))")
                            try insertSmt.exec([])
                            
                            //Add main trip navigation object
                            //Trip is saved
                            DashboardVC.tripNavObj = self.navigationObj!
                            
                            //Get SQL Trip ID
                            let tripSelectSmt = try con.prepare("SELECT MAX(_id) FROM trips")
                            result = try tripSelectSmt.query([])
                            var row = try result.readRow()
                            let tripID = row?["MAX(_id)"]
                            tripSqlID = tripID as? Int
                            print("=====> Trip SQL ID: \(tripSqlID!)")
                            myPreferences.tripSqlID = tripSqlID!
                            myPreferences.userSqlID = userSqlID!
                            
                            self.addTripWith(tripID: tripSqlID!, userID: userSqlID!, currentLoc: self.currentLoc!, startLoc: self.navigationObj.startLoc!, endLoc: self.navigationObj.endLoc!, placeName: self.navigationObj.destName!, trackName: "")
                            
                            myPreferences.tripEndLocation = self.navigationObj.endLoc!
                            myPreferences.tripDestName = self.navigationObj.destName!
                            
                            self.processInvite()
                            
                        }catch (let error) {
                            print("Error in Mapping: \(error)")
                        }
                        
                    }
                }
            }
            try con.close()
        }
        catch (let e) {
            print(e)
        }
        
        
        
        
    }
    
    
    func processInvite() {
        
        if tripSqlID != nil && userSqlID != nil {
            do{
                try con.open("35.185.34.14", user: "diparth", passwd: "diparthpatel309")
                try con.use(db_name)
                //Add user and trip to mapping
                let insertMapSmt = try con.prepare("INSERT INTO trips_user_mapping(trip_id, user_id) VALUES(?,?)")
                try insertMapSmt.exec([tripSqlID!,userSqlID!])
                try con.close()
            }catch(let e) {
                print("Mapping Error: \(e)")
            }
        }
        
        if GIDSignIn.sharedInstance().currentUser != nil {
            if let invite = FIRInvites.inviteDialog() {
                invite.setInviteDelegate(self)

                invite.setMessage("Join the trip with: \(GIDSignIn.sharedInstance().currentUser.profile.name!)")
                invite.setTitle("Share The Trip")
                invite.setDeepLink("https://t89ss.app.goo.gl/?apn=net.dhruvpatel.travelomate&ibi=com.dpate168.TraveloMateApp&link=http://35.185.102.127:8080/travelomate/invite/\(tripSqlID!)")
                //invite.setDeepLink("https://t89ss.app.goo.gl/?link=http://35.185.102.127:8080/travelomate/invite/\(tripSqlID!)&ibi=com.dpate168.TraveloMateApp&apn=net.dhruvpatel.travelomate")
                
                print("https://t89ss.app.goo.gl/?link=http://35.185.102.127:8080/travelomate/invite/\(tripSqlID!)&ibi=com.dpate168.TraveloMateApp&apn=net.dhruvpatel.travelomate")
                
                invite.setCallToActionText("Install")
                invite.open()
                
            }
        }
    }
    
    //This will add new trip with first user (initiator) to firebase DB.
    func addTripWith(tripID: Int,userID: Int, currentLoc: CLLocation, startLoc: CLLocation, endLoc: CLLocation, placeName: String, trackName: String ) {
        
        firebaseDataReference = FIRDatabase.database().reference(withPath: "trips/")
        
        firebaseDataReference.updateChildValues(["\(tripID)": ["currentUserLocation":["user:\(userID)":["userName":userFname!,
                                                                                                        "userProPic":"\(userPicUrl!)",
                                                                                                        "x":currentLoc.coordinate.latitude,
                                                                                                   "y":currentLoc.coordinate.longitude]],
                                                               "endPoint":["x":endLoc.coordinate.latitude,
                                                                           "y":endLoc.coordinate.longitude],
                                                               "midPoint":["userID":userID,
                                                                           "placeName":"",
                                                                           "x":0.0,
                                                                           "y":0.0],
                                                               "music":["autoSync": false,
                                                                        "track":"nil"],
                                                               "placeName":placeName,
                                                               "startPoint":["x":startLoc.coordinate.latitude,
                                                                             "y":startLoc.coordinate.longitude]]])
        NotificationCenter.default.post(name: Notification.Name.init("UserHasAddedMidPoint"), object: nil)
        
        
        isUserAllowedToUpdateLoc = true
        myPreferences.isUserAllowedToUpdateLoc = true
        
//        let prefData = NSKeyedArchiver.archivedData(withRootObject: myPreferences)
//        userDefaults.set(prefData, forKey: "previousPreferences")
//        userDefaults.set(true, forKey: "isPreferencesAvail")
//        userDefaults.synchronize()

    }
    
    func updateUserLocTo(location: CLLocation) {
    
        firebaseDataReference = FIRDatabase.database().reference(withPath: "trips/\(tripSqlID!)/currentUserLocation/user:\(userSqlID!)/")
        firebaseDataReference.updateChildValues(["x":location.coordinate.latitude,
                                                 "y":location.coordinate.longitude])
    }
    
    
}

