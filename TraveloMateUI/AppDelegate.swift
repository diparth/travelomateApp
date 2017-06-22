//
//  AppDelegate.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 3/15/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GoogleMaps
import Alamofire
import GooglePlaces
import GoogleSignIn

//Spotify client id: 731c6c19324c47f785f482dc01c011b5
//Client secret: 71578effd89248aca8e3898944dab38c
//Redirect URL: com.travelomate://spotify-auth-callback

let appDelegate = UIApplication.shared.delegate as? AppDelegate
let userDefaults = UserDefaults.standard
var globalSession: SPTSession!
var isSongPlaying: Bool!

var myPreferences = Preferences.init()
let con = MySQL.Connection()
let db_name = "travelomate"
var firebaseDataReference : FIRDatabaseReference!
var isUserAllowedToUpdateLoc = false

//Bool variable to switch to navigation from dashboard
var ifTripReceived: Bool!
var endLat: Double!
var endLng: Double!
var endLocName: String!
var tripUsers = [Users]()
var bearingAngle: CLLocationDirection!

//Sinch client
var globalSinchClient: SINClient!


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, GIDSignInUIDelegate, SINClientDelegate{

    var window: UIWindow?
    var auth = SPTAuth.defaultInstance()
    var player: SPTAudioStreamingController!
    var navigationVC: NavigationVC!
    
    
    //Sinch client
    var client: SINClient?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        GMSServices.provideAPIKey("AIzaSyBbyuHBfCtVo18k885B5yVdX_XKgGT2yUg")
        GMSPlacesClient.provideAPIKey("AIzaSyBbyuHBfCtVo18k885B5yVdX_XKgGT2yUg")
        
        auth?.clientID = kSPT_CLIENT_ID
        auth?.redirectURL = URL.init(string: kSPT_CALLBACK_URL)
        auth?.requestedScopes = [SPTAuthStreamingScope]
        auth?.sessionUserDefaultsKey = kSPT_SESSION_USER_KEY
        player = SPTAudioStreamingController.sharedInstance()
        
        
        
        if(userDefaults.value(forKey: "isPreferencesAvail")) != nil {
            if(userDefaults.bool(forKey: "isPreferencesAvail") == true) {
                if let prevPrefData = userDefaults.object(forKey: "previousPreferences") as? Data{
                    let pref = NSKeyedUnarchiver.unarchiveObject(with: prevPrefData)  as? Preferences
                    self.setDefaultsFrom(pref: pref!)
                }
            }
        }
        
        
        bearingAngle = 0
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("UserDidLoginNotification"), object: nil, queue: nil) { (notification) in
            self.initSinchClient(userid: (notification.userInfo?["userID"] as? String)!)
        }
        
        return true
    }
    
    
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("The URL is: \(url)")
        
        
        //Handle Spotify login callback
        if (auth?.canHandle(url))! {
            auth?.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                
                if error != nil {
                    print("Auth error is: \(String(describing: error))")
                    userDefaults.set(false, forKey: "sessionAvailable")
                    return
                }else {
                    self.auth?.session = session
                    globalSession = session!
                    let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                    userDefaults.set(true, forKey: "sessionAvailable")
                    userDefaults.set(sessionData, forKey: "spotifySession")
                    userDefaults.synchronize()
                    NotificationCenter.default.post(name: NSNotification.Name.init("sessionUpdated"), object: self)
//                    try! self.player?.start(withClientId: appDelegate?.auth?.clientID, audioController: nil, allowCaching: true)
//                    self.player?.diskCache = SPTDiskCache() /* capacity: 1024 * 1024 * 64 */
                //    self.player?.login(withAccessToken: appDelegate?.auth?.session.accessToken)
                    print("Session updated with: \(String(describing: self.auth?.session!))")
                }
                
            })
        }
        
        
        //Handle Google login callback
        if(GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])) {
            return true
        }
        
        if (self.application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "")) {
            return true
        }
        
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let invite = FIRInvites.handle(url, sourceApplication:sourceApplication, annotation:annotation) as? FIRReceivedInvite {
            let matchType =
                (invite.matchType == .weak) ? "Weak" : "Strong"
            print("Invite received from: \(sourceApplication ?? "") Deeplink: \(invite.deepLink)," +
                "Id: \(invite.inviteId), Type: \(matchType)")
            return true
        }
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
        
            let linkHandled = FIRDynamicLinks.dynamicLinks()?.handleUniversalLink(incomingURL, completion: { (dynamicLink, error) in
                if let dynamiclink = dynamicLink, let _ = dynamicLink?.url {
                    self.handleIncomingDynamicLink(dynamiclink: dynamiclink)
                }
            })
            return linkHandled!
        }
        return false
    }
    
    
    
    
    func handleIncomingDynamicLink(dynamiclink: FIRDynamicLink) {
        var urlStr = "\(dynamiclink.url!)"
        urlStr = urlStr.replacingOccurrences(of: "https://t89ss.app.goo.gl/?", with: "")
        urlStr = urlStr.replacingOccurrences(of: "link=http://35.185.102.127:8080/travelomate/invite/", with: "")
        urlStr = urlStr.replacingOccurrences(of: "ibi=com.dpate168.TraveloMateApp", with: "")
        urlStr = urlStr.replacingOccurrences(of: "apn=net.dhruvpatel.travelomate", with: "")
        urlStr = urlStr.replacingOccurrences(of: "&", with: "")
        print("Trip sql id is: \(urlStr)")
        print("Dynamic link parameters are: \(dynamiclink.url!)")
        tripSqlID = Int.init(urlStr)
        
        myPreferences.tripSqlID = tripSqlID!
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
//        let user = GIDSignIn
//        userFname = user.profile.givenName!
//        userLname = user.profile.familyName!
//        userEmailID = user.profile.email!
//        userPicUrl = user.profile.imageURL(withDimension: UInt.min)!
//        print("Name:\(userFname!) \(userLname!)")
//        processUserWith(id: userEmailID!)
//        

    }
    
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("Error in google signin: \(error)")
        }else {
            if let _ = user.profile.name{
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
                    myPreferences.userSqlID = userSqlID!
                    print("=========>> Sql ID: \(userSqlID!)")
                    NotificationCenter.default.post(name: NSNotification.Name.init("UserDidLoginNotification"), object: nil, userInfo: ["userID": "\(userSqlID!)"])
                }
                self.getNavigationDetails()
            }
            try con.close()
        }catch(let error) {
            print("Error in sql: \(error)")
        }
        
        if(tripSqlID != nil && userSqlID != nil) {
            do {
                // open a new connection
                try con.open("35.185.34.14", user: "diparth", passwd: "diparthpatel309")
                try con.use(db_name)
                if userEmailID != nil {
                    
                    //var selectSmt = try con.prepare("SELECT * FROM user WHERE _id<>\"\(userSqlID!)\"")
                    print("Trip users Query: select distinct(u._id),u.first_name,u.last_name,u.email,u.pro_pic from user u, trips_user_mapping tm where tm.trip_id = \(tripSqlID!) and tm.user_id <> \(userSqlID!) and u._id = tm.user_id")
                    let selectSmt = try con.prepare("select distinct(u._id),u.first_name,u.last_name,u.email,u.pro_pic from user u, trips_user_mapping tm where tm.trip_id = \(tripSqlID!) and tm.user_id <> \(userSqlID!) and u._id = tm.user_id")
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
                            print("\(tripUsers)")
                        }
                    }
                    
                }
                try con.close()
            }catch(let e) {
                print("Error: \(e)")
            }
        }
        
    }
    
    
    func getNavigationDetails() {
    
        do {
            try con.open("35.185.34.14", user: "diparth", passwd: "diparthpatel309")
            try con.use(db_name)
            
            let selectTripSmt = try con.prepare("SELECT * FROM trips WHERE _id=\(tripSqlID!)")
            let result = try selectTripSmt.query([])
            let rows = try result.readAllRows()
            print("\(rows!)")
            if (rows?.count)! > 0 {
                endLat = rows?[0][0]["end_lat"] as! Double!
                endLng = rows?[0][0]["end_lng"] as! Double!
                
                print("=========>> Lat Long: \(endLat!) : \(endLng!)")
                
                self.processJSONData {
                    
                }
            }
            try con.close()
        }catch(let error) {
            print("Error: \(error)")
        }
        if tripSqlID != nil && userSqlID != nil {
            do{
                try con.open("35.185.34.14", user: "diparth", passwd: "diparthpatel309")
                try con.use(db_name)
                //Add user and trip to mapping
                let insertMapSmt = try con.prepare("INSERT INTO trips_user_mapping(trip_id, user_id) VALUES(?,?)")
                try insertMapSmt.exec([tripSqlID!,userSqlID!])
                self.updateUserWith(userID: userSqlID!, currentLoc: DashboardVC.currentLoc!)
                myPreferences.tripSqlID = tripSqlID!
                NotificationCenter.default.post(name: Notification.Name.init("UserHasAddedMidPoint"), object: nil)
                try con.close()
            }catch(let e) {
                print("Mapping Error: \(e)")
            }
        }
    }
    
    
    func processJSONData(completed: @escaping DownloadComplete) {
        
        let urlstr = "https://maps.googleapis.com/maps/api/directions/json?origin=\(DashboardVC.currentLoc.coordinate.latitude),\(DashboardVC.currentLoc.coordinate.longitude)&destination=\(endLat!),\(endLng!)&key=\(GMS_PLACE_KEY)"
        let url = URL.init(string: urlstr)
        print("\(url!)")
        
        Alamofire.request(url!).responseJSON { (response) in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, Any> {
                if let routes = dict["routes"] as? [Dictionary<String, Any>] {
                    if routes.count > 0 {
                        if let legs = routes[0]["legs"] as? [Dictionary<String, Any>] {
                            self.navigationVC = NavigationVC()
                            self.navigationVC.navigationObj = Navigation.init(myData: legs[0], name: "")
                            if self.navigationVC.navigationObj != nil {
                                DashboardVC.tripNavObj = self.navigationVC.navigationObj
                                myPreferences.tripEndLocation = DashboardVC.tripNavObj.endLoc!
                                myPreferences.tripDestName = DashboardVC.tripNavObj.destName!
                                ifTripReceived = true
                                
                                
                                //self.performSegue(withIdentifier: "navigationView", sender: self)
                            }
                        }
                    }else {
                        let alert = UIAlertController.init(title: "Oops!", message: "Sorry!, trip data is not coming through.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction.init(title: "Ok", style: .cancel, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
            completed()
        }
        
    }
    
    
    
    
//    @available(iOS 8.0, *)
//    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
//        
//        guard let dynamicLinks = FIRDynamicLinks.dynamicLinks() else {
//            return false
//        }
//        
//        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamicLink, error) in
//            
//        }
//        
//        if handled {
//            //let message = "continueUserActivity webPageURL:\n\(userActivity.webpageURL?.absoluteString ?? "")"
//            //self.showDeepLinkAlertView(withMessage: message)
//        }
//        
//        return handled
//    }
    
    
    
    func generateDynamicLinkMessage(_ dynamicLink: FIRDynamicLink) -> String {
        let matchConfidence: String
        if dynamicLink.matchConfidence == .weak {
            matchConfidence = "Weak"
        } else {
            matchConfidence = "Strong"
        }
        let message = "App URL: \(dynamicLink.url?.absoluteString ?? "")\nMatch Confidence: \(matchConfidence)\n"
        return message
    }
    
    
    
    
    @available(iOS 8.0, *)
    func showDeepLinkAlertView(withMessage message: String) {
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) -> Void in
            print("OK")
        }
        
        let alertController = UIAlertController.init(title: "Deep-link Data", message: message, preferredStyle: .alert)
        alertController.addAction(okAction)
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    
    func updateUserWith(userID: Int, currentLoc: CLLocation) {
        
        if(userSqlID != nil && tripSqlID != nil) {
            firebaseDataReference = FIRDatabase.database().reference(withPath: "trips/\(tripSqlID!)/currentUserLocation/")
            firebaseDataReference.updateChildValues(["user:\(userSqlID!)":["userName":userFname!,
                                                                           "userProPic":"\(userPicUrl!)",
                                                                           "x":DashboardVC.currentLoc.coordinate.latitude,
                                                                           "y":DashboardVC.currentLoc.coordinate.longitude]])
            isUserAllowedToUpdateLoc = true
            myPreferences.isUserAllowedToUpdateLoc = true
            
        }
//        let prefData = NSKeyedArchiver.archivedData(withRootObject: myPreferences)
//        userDefaults.set(prefData, forKey: "previousPreferences")
//        userDefaults.set(true, forKey: "isPreferencesAvail")
//        userDefaults.synchronize()

    }
    
    
    func setDefaultsFrom(pref: Preferences) {
    
        userFname = pref.userFname!
        userLname = pref.userLname!
        userSqlID = pref.userSqlID!
        userEmailID = pref.userEmailID!
        userPicUrl = pref.userPicUrl!
        tripSqlID = pref.tripSqlID!
        DashboardVC.tripNavObj = Navigation.init(endloc: pref.tripEndLocation!, destName: pref.tripDestName!)
        tripUsers = pref.tripSharedUsers
        isUserAllowedToUpdateLoc = pref.isUserAllowedToUpdateLoc
        
        myPreferences = Preferences.init(pref: pref)
        NotificationCenter.default.post(name: Notification.Name.init("UserHasAddedMidPoint"), object: nil)
        
        print("***********************************\n======= User Preferences ======\n*** UserSQL:\(myPreferences.userSqlID!)  TripSQL:\(myPreferences.tripSqlID!)  ***\n***********************************")
        
    }
    
    
    
    //MARK: Sinch delegate methods
    
    
    func initSinchClient(userid: String){
        
        if (client == nil){
            client = Sinch.client(withApplicationKey: kSINCH_KEY,applicationSecret: kSINCH_SECRET,environmentHost: kSINCH_HOST,userId: userid)
            
            client?.delegate = self
            client?.setSupportCalling(true)
            client?.start()
            client?.startListeningOnActiveConnection()
        }
        
    }
    
    func clientDidStart(_ client: SINClient!) {
        print("Sinch client has started successfully with version: \(Sinch.version()) and ID: \((client.userId)!)")
        globalSinchClient = client!
        print("Global sinch client id: \((globalSinchClient.userId)!)")

    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("Sinch client error: \(error)")
    }
    
    
    
    //Save user settings
    
//    func saveUserPreferences() {
//        let encodedData = NSKeyedArchiver.archivedData(withRootObject: myPreferences)
//        userDefaults.set(encodedData, forKey: "previousPreferences")
//        userDefaults.set(true, forKey: "")
//        userDefaults.synchronize()
//        
//    }

    
    
    
    
    
    //MARK: Other delegate methods
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //userDefaults.set(myPreferences, forKey: "previousPreferences")
        //userDefaults.set(true, forKey: "isPreferencesAvail")
        //userDefaults.synchronize()

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        /*
        if(DashboardVC.tripNavObj != nil) {
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: myPreferences)
            userDefaults.set(encodedData, forKey: "previousPreferences")
            userDefaults.set(true, forKey: "isPreferencesAvail")
            userDefaults.synchronize()
            print("======>  Preferences saved!  <======")
        }
        */
        
        //userDefaults.set(myPreferences, forKey: "previousPreferences")
        //userDefaults.set(true, forKey: "isPreferencesAvail")
        //userDefaults.synchronize()

        
        
    }


}

