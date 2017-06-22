//
//  DashboardVC.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 3/15/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit
import Speech
import Alamofire
import AVFoundation
import CoreLocation
import Firebase
import FirebaseDatabase
import GoogleSignIn



var speechSynthesizer = AVSpeechSynthesizer()
var speechUtterance = AVSpeechUtterance()



var midPointPlaceName: String! = ""
var midPointLocation: CLLocation! = CLLocation.init(latitude: 0.0, longitude: 0.0)
var midPointUserID: Int! = 0


class DashboardVC: UIViewController, SFSpeechRecognizerDelegate, CLLocationManagerDelegate, UITextViewDelegate, GIDSignInDelegate, GIDSignInUIDelegate, SINCallClientDelegate {

    //MARK: IBOutlets
    
    @IBOutlet var dashboardImg: UIImageView!
    @IBOutlet var RecordButton: UIButton!
    @IBOutlet weak var displaySpeech: UITextView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var AmPmLabel: UILabel!
    @IBOutlet weak var currentCity: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var currentSpeed: UILabel!
    @IBOutlet var weatherImage: UIImageView!
    
    @IBOutlet weak var buttonBox: UIView!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var gasButton: UIButton!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var tripUsersButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    
    //MARK: Variables
    
    var locationManager = CLLocationManager()
    static var currentLoc : CLLocation!
    
    var responseType: String!
    var responseCount: Int!
    var ifDirectionResponsePresent = false
    var responseSpeech: String!
    var initiateResponseAnswer: Bool!
    
    //Spotify
    var firstLoad: Bool!
    var auth = appDelegate?.auth
    
    //Class objects
    static var navObj: Navigation!
    static var tripNavObj: Navigation!
    var navigation : Navigation!
    var places = [Place]()
    var weather : Weather!
    var album: Album!
    var track: Track!
    var artist: Artist!
    var segSubID: String!
    
    //Sinch var
    var remoteUser: Users!
    
    //Speech variables
    var transcribedText: String!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    
    //MARK: Other methods
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    
    func setLayoutRadius() {
        
        self.RecordButton.layer.cornerRadius = 40
        self.navigationButton.layer.cornerRadius = 15
        self.tripUsersButton.layer.cornerRadius = 15
        self.playerButton.layer.cornerRadius = 15
        self.gasButton.layer.cornerRadius = 15
        self.foodButton.layer.cornerRadius = 15
        self.settingsButton.layer.cornerRadius = 25
        
        self.displaySpeech.layer.cornerRadius = 15
        self.buttonBox.layer.cornerRadius = 15
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayoutRadius()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.displaySpeech.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        self.displaySpeech.isHidden = true
        foodButton.isEnabled = false
        gasButton.isEnabled = false
        navigationButton.isEnabled = false
        playerButton.isEnabled = false
        RecordButton.isEnabled = false
        tripUsersButton.isEnabled = false
        
        speechRecognizer?.delegate = self
        transcribedText = ""
        //RecordButton.setBackgroundImage(UIImage.init(named: "microphone"), for: .normal)
        
        appDelegate?.auth?.renewSession(self.auth?.session, callback: { (error, session) in
            if session != nil {
                self.auth?.session = session
            }else {
                print("Error in refreshing session: \(String(describing: error))")
            }
        })
        
        

        
        
        
        
        if (CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
            self.initializeViewDidLoad()
        }
        if appDelegate?.auth?.session != nil {
            let session = NSKeyedUnarchiver.unarchiveObject(withFile: "spotifySession") as? SPTSession
            appDelegate?.auth?.session = session
        }
        
        
        if(GIDSignIn.sharedInstance().currentUser == nil) {
            GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().signIn()
        }else {
            GIDSignIn.sharedInstance().signInSilently()
        }
        
        if ifTripReceived != nil {
            if ifTripReceived == true {
                performSegue(withIdentifier: "navigationView", sender: self)
            }
        }

        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillTerminate, object: nil, queue: nil) { (notification) in
            self.saveUserDefaults()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("UserHasAddedMidPoint"), object: nil, queue: nil) { (notification) in
            self.fetchMidPoint()
        }
        
        self.checkNotification()
//        self.firstLoad = true
    }
    
    
    
    func saveUserDefaults() {
        if(DashboardVC.tripNavObj != nil) {
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: myPreferences)
            userDefaults.set(encodedData, forKey: "previousPreferences")
            userDefaults.set(true, forKey: "isPreferencesAvail")
            userDefaults.synchronize()
            print("======>  Preferences saved!  <======")
            print("***********************************\n======= User Preferences ======\n*** UserSQL:\(myPreferences.userSqlID!)  TripSQL:\(myPreferences.tripSqlID!)  ***\n***********************************")
        }
    }
    
    
    
    
    func initializeViewDidLoad() {
    
        foodButton.isEnabled = true
        gasButton.isEnabled = true
        navigationButton.isEnabled = true
        playerButton.isEnabled = true
        tripUsersButton.isEnabled = true
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        locationManager.startUpdatingLocation()
        
        DashboardVC.currentLoc = locationManager.location!
        setClock()
        updateWeather()
        
        
        NotificationCenter.default.post(name: Notification.Name.init("UserHasAddedMidPoint"), object: nil)
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
            switch authStatus{
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            OperationQueue.main.addOperation {
                self.RecordButton.isEnabled = isButtonEnabled
            }
        }
                
    }

    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.startUpdatingLocation()
            self.initializeViewDidLoad()
        }else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setClock()
        print("Session in view did appear: \(String(describing: appDelegate?.auth?.session))")
        if appDelegate?.auth?.session == nil {
            
            if let sessionObj = userDefaults.object(forKey: "spotifySession") {
                let sessionData = sessionObj as! Data
                appDelegate?.auth?.session = NSKeyedUnarchiver.unarchiveObject(with: sessionData) as! SPTSession
            }
            checkNotification()
        }
        if DashboardVC.currentLoc != nil{
            updateWeather()
        }
        
        //Fetch users of the trip is new
        if(tripSqlID != nil && userSqlID != nil) {
            self.fetchTripUsers()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //Sinch call client
        if(globalSinchClient != nil) {
            globalSinchClient.call().delegate = self
            
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
                        }
                        myPreferences.tripSharedUsers = tripUsers
                    }
                    
                }
                try con.close()
            }catch(let e) {
                print("Error: \(e)")
            }
        }
        
    }
    
    
    func fetchUserWith(id: String) {
        let id = Int.init(id)
        if(tripSqlID != nil && userSqlID != nil) {
            do {
                // open a new connection
                try con.open("35.185.34.14", user: "diparth", passwd: "diparthpatel309")
                try con.use(db_name)
                if userEmailID != nil {
                    
                    //var selectSmt = try con.prepare("SELECT * FROM user WHERE _id<>\"\(userSqlID!)\"")
                    let selectSmt = try con.prepare("select * from user where _id = \(id!)")
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
                            self.remoteUser = Users.init(id: id, fName: fname, lName: lname, email: email, picStr: picStr)
                        }
                    }
                    
                }
                try con.close()
            }catch(let e) {
                print("Error: \(e)")
            }
        }
    }
    
    
    
    var timer = Timer()
    func setClock(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(DashboardVC.setClock), userInfo: nil, repeats: false)
        let time = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeStyle = .short
        let str = dateFormatter.string(from: time)
        let strArr = str.components(separatedBy: " ")
        self.currentTime.text = strArr[0]
        self.AmPmLabel.text = strArr[1]
    }
    var timer2 = Timer()
    func updateWeather() {
        timer2 = Timer.scheduledTimer(timeInterval: 13*60, target: self, selector: #selector(DashboardVC.updateWeather), userInfo: nil, repeats: false)
        let url = URL.init(string: "http://35.185.102.127:8080/travelomate/parseVoice?speech=weather&lat=\(DashboardVC.currentLoc.coordinate.latitude)&lng=\(DashboardVC.currentLoc.coordinate.longitude)")
        Alamofire.request(url!).responseJSON { (response) in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, Any> {
                if let data = dict["data"] as? Dictionary<String, Any> {
                    var temp = ""
                    var wtype = ""
                    if let condition = data["condition"] as? String {
                        wtype = condition
                    }
                    if let tmp = data["temperature"] as? Int {
                        temp = "\(tmp)"
                    }
                    self.weatherLabel.text = "\(temp)° | \(wtype)"
                    self.weatherImage.image = UIImage.init(named: wtype)
                }
            }
        }
        
        let cityNameUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(DashboardVC.currentLoc.coordinate.latitude),\(DashboardVC.currentLoc.coordinate.longitude)&key=AIzaSyBbyuHBfCtVo18k885B5yVdX_XKgGT2yUg"
        let url2 = URL.init(string: cityNameUrl)
        Alamofire.request(url2!).responseJSON { (response) in
            let result = response.result
            if let dict = result.value as? Dictionary<String, Any> {
                if let results = dict["results"] as? [Dictionary<String, Any>] {
                    if let addresses = results[0]["address_components"] as? [Dictionary<String, Any>] {
                        if let city = addresses[2]["long_name"] as? String {
                            self.currentCity.text = city
                        }
                    }
                }
            }
        }
        
    }
    
    //Midpoint Start
    var timer3 = Timer()
    func fetchMidPoint() {
        timer2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DashboardVC.fetchMidPoint), userInfo: nil, repeats: false)
        //print("user sql:\(userSqlID!)   tripsql:\(tripSqlID!)")
        if(userSqlID != nil && tripSqlID != nil) {
            
            firebaseDataReference = FIRDatabase.database().reference(withPath: "trips/\(tripSqlID!)/midPoint/")
            let refHandle = firebaseDataReference.observe(.value, with: { (snapshot) in
                var tempLoc: CLLocation!
                var tempPlaceName: String!
                if let resultDict = snapshot.value as? Dictionary<String, Any> {
                    
                    if let placename = resultDict["placeName"] as? String {
                        tempPlaceName = placename
                    }
                    if let midLat = resultDict["x"] as? Double {
                        if let midLog = resultDict["y"] as? Double {
                            tempLoc = CLLocation.init(latitude: midLat, longitude: midLog)
                        }
                    }
                    if let userid = resultDict["userID"] as? Int {
                        midPointUserID = userid
                    }
                    print("Midpoint:------> Lat:\(tempLoc.coordinate.latitude) Long:\(tempLoc.coordinate.longitude)")
                }
                
                if(midPointPlaceName != nil && midPointLocation != nil && midPointUserID != nil && tempLoc != nil && tempPlaceName != nil) {
                    if(tempLoc.coordinate.latitude != midPointLocation.coordinate.latitude && tempLoc.coordinate.longitude != midPointLocation.coordinate.longitude) {
                        
                        midPointLocation = tempLoc!
                        midPointPlaceName = tempPlaceName!
                        
                        if(midPointPlaceName != "" && midPointLocation.coordinate.latitude != 0.0 && midPointLocation.coordinate.longitude != 0.0 && midPointUserID != nil) {
                            if(midPointUserID != 3) {
                                let alert = UIAlertController.init(title: "Hi, there.", message: "Your friend is going to \(midPointPlaceName!). Would you like to join?", preferredStyle: .alert)
                                alert.addAction(UIAlertAction.init(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
                                alert.addAction(UIAlertAction.init(title: "Yes!", style: UIAlertActionStyle.default, handler: { (action) in
                                    self.navigateToMidpoint()
                                }))
                                
                                self.present(alert, animated: true, completion: { _ in })
                                if(midPointLocation != nil) {
                                    self.processMidpointJSONData {
                                        print("Inside Midpoint JSON")
                                    }
                                }
                            }
                        }
                    }
                }
            })
            print("refHandle: \(refHandle)")
            
        }
        
    }
    
    func navigateToMidpoint() {
        if(self.navigation != nil) {
            DashboardVC.navObj = self.navigation
            performSegue(withIdentifier: "navigationView", sender: self)
        }
        
    }
    
    func processMidpointJSONData(completed: @escaping DownloadComplete) {
        //        let urlstr = "https://maps.googleapis.com/maps/api/directions/json?origin=\(DashboardVC.currentLoc.coordinate.latitude),\(DashboardVC.currentLoc.coordinate.longitude)&destination=\(midPointLocation.coordinate.latitude),\(midPointLocation.coordinate.longitude)&key=\(GMS_PLACE_KEY)"
        let urlstr = "https://maps.googleapis.com/maps/api/directions/json?origin=\(DashboardVC.currentLoc.coordinate.latitude),\(DashboardVC.currentLoc.coordinate.longitude)&destination=\(midPointLocation.coordinate.latitude),\(midPointLocation.coordinate.longitude)&key=\(GMS_PLACE_KEY)"
        let navUrl = URL.init(string: urlstr)
        
        print("\(navUrl!)")
        Alamofire.request(navUrl!).responseJSON { (response) in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, Any> {
                if let routes = dict["routes"] as? [Dictionary<String, Any>] {
                    if let legs = routes[0]["legs"] as? [Dictionary<String, Any>] {
                        let newNavObj = Navigation.init(myData: legs[0], name: "")
                        self.navigation = newNavObj
                    }
                }
            }
            completed()
        }
        
    }
    
    //Midpoint end
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last!
        DashboardVC.currentLoc = location
        if (DashboardVC.currentLoc.speed > 0){
            self.currentSpeed.text = "\(Int(Double(round((DashboardVC.currentLoc.speed)*2.23694)))) Mph"
        }else {
            self.currentSpeed.text = "0 Mph"
        }
        print("Dbl:\(DashboardVC.currentLoc.speed) Int:\(Int(DashboardVC.currentLoc.speed))")
        //print("\(DashboardVC.currentLoc)")
    }
    
    //MARK: Recording methods
    
    @IBAction func RecordTapped(_ sender: Any) {
        
        self.processRecordingAndAudioSession()
    }
    
    //This method simply check if recording is on or off and turn it on or off
    func processRecordingAndAudioSession() {
    
        if audioEngine.isRunning {
            //Stops recording
            
            CATransaction.begin()
            CATransaction.setValue(NSNumber.init(value: 0.8), forKey: kCATransactionAnimationDuration)
            self.headerView.alpha = 1.0
            self.displaySpeech.isHidden = true
            CATransaction.commit()
            
            self.displaySpeech.text = ""
            audioEngine.stop()
            recognitionRequest?.endAudio()
            RecordButton.isEnabled = false
            //RecordButton.setBackgroundImage(UIImage.init(named: "microphone.png"), for: .normal)
            if (self.transcribedText != nil && self.initiateResponseAnswer == nil) {
                self.processSpeechWith(myspeech: self.transcribedText)
            }
        } else {
            //Starts recording
            speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            startRecording()
            
            CATransaction.begin()
            CATransaction.setValue(NSNumber.init(value: 0.8), forKey: kCATransactionAnimationDuration)
            self.headerView.alpha = 0.2
            self.displaySpeech.isHidden = false
            self.displaySpeech.text = "Say something!"
            CATransaction.commit()
            
            self.displaySpeech.isEditable = true
            
            //RecordButton.setBackgroundImage(UIImage.init(named: "mute.png"), for: .normal)
            self.responseType = nil
            self.responseCount = nil
            self.ifDirectionResponsePresent = false
            self.initiateResponseAnswer = nil
            //self.segSubID = nil
        }
    }
    
    //This method starts audio session and get transcription from speech
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setMode(AVAudioSessionModeDefault)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch {
            print("AudioSession properties weren't set because of an error.")
        }
        
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                let transcribedString = result?.bestTranscription.formattedString
                
                self.transcribedText = transcribedString?.lowercased()
                self.displaySpeech.text = transcribedString
                print(transcribedString!)
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.RecordButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        //transcribedText = "Say something, I'm listening!"
        
    }
    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            RecordButton.isEnabled = true
        } else {
            RecordButton.isEnabled = false
        }
    }
    
    
    @IBAction func speakTextPressed(_ sender: Any) {
        self.speakTextWithString(mytext: transcribedText)
        
    }
    
    open func speakTextWithString(mytext: String) {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        speechUtterance = AVSpeechUtterance(string: mytext)
        
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        
        speechUtterance.pitchMultiplier = 1
        speechUtterance.volume = 1
        //RecordButton.setBackgroundImage(UIImage.init(named: "microphone.png"), for: .normal)
        speechSynthesizer.speak(speechUtterance)
        //transcribedText = ""

    }
    
    
    
    open func processSpeechWith(myspeech: String) {
    
//        if (transcribedText == "settings" || transcribedText == "open settings") {
//            SwitchSegueWith(myspeech: transcribedText)
//            
//        }else if (transcribedText.contains("navigate") && transcribedText.contains("nearest")) {
//            SwitchSegueWith(myspeech: transcribedText)
//        }
    
        self.processDataFromJSON {
        }
        print("inside processSpeechWith")
    
    }
    
    func resetConditionalParams() {
    
        self.responseType = nil
        self.responseCount = nil
        self.ifDirectionResponsePresent = false
        self.initiateResponseAnswer = nil
        self.transcribedText = ""
        self.responseSpeech = nil
    }
    
    
    func processDataFromJSON(completed: @escaping DownloadComplete) {
        
        //Local Variables
        var requestType = String()
        
        var tempStr = ""
        if transcribedText != "" {
            tempStr = "\(BASE_URL)\(transcribedText!)\(LAT_URL)\(DashboardVC.currentLoc.coordinate.latitude)\(LONG_URL)\(DashboardVC.currentLoc.coordinate.longitude)"
        }else {
            tempStr = "\(BASE_URL)\(LAT_URL)\(DashboardVC.currentLoc.coordinate.latitude)\(LONG_URL)\(DashboardVC.currentLoc.coordinate.longitude)"
        }
        //tempStr = "http://35.185.102.127:8080/travelomate/parseVoice?speech=play songs by hardwell&lat=40.56927012&lng=-74.54811841"
        let myURL = URL.init(string: tempStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        Alamofire.request(myURL!).responseJSON { (response) in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, Any>{
                if dict["directions"] != nil {
                    self.ifDirectionResponsePresent = true
                }
                if let type = dict["type"] as? String{
                    self.responseType = type
                    if let req_type = dict["request_type"] as? String{
                        requestType = req_type
                    }
                }
                if let count = dict["count"] as? Int{
                    self.responseCount = count
                }
                if let response = dict["response"] as? Dictionary<String, Any>{
                    if let respText = response["text"] as? String{
                        
                        self.responseSpeech = respText.components(separatedBy: " Should I ")[0]
                    }
                    if let obj = response["initiate_response_answer"] as? Bool{
                        self.initiateResponseAnswer = obj
                    }
                }
                if self.responseType != nil {
                
                    if (self.responseType == "place") {
                        if self.ifDirectionResponsePresent == true{
                            //1) For direct navigation to place
                            if self.responseCount == 1{
                                self.navigation = Navigation.init(navigationDict: dict)
                                DashboardVC.navObj = self.navigation
                                self.segSubID = "navigationView"
                                self.speakTextWithString(mytext: "\(self.responseSpeech!) Please, proceed towards highlighted route.")
                                self.updateMidPointWith(navigation: self.navigation)
                                self.SwitchSegueWith(subID: self.segSubID)
                                self.resetConditionalParams()
                                //self.processResponse()
                            }
                        }else if self.ifDirectionResponsePresent == false {
                            //2) For list of places
                            if let data = dict["data"] as? [Dictionary<String, Any>] {
                                self.places = [Place]()
                                if self.places.count == 0{
                                    for place in data{
                                        self.places.append(Place.init(placeDict: place))
                                    }
                                }
                            }
                            self.speakTextWithString(mytext: self.responseSpeech)
                            self.segSubID = "placesView"
                            self.SwitchSegueWith(subID: self.segSubID)
                            self.resetConditionalParams()
                        }
                        
                    }else if (self.responseType == "weather") {
                        //3) For weather from anywhere
                        if let data = dict["data"] as? Dictionary<String, Any> {
                            self.weather = Weather.init(dataDict: data)
                            self.segSubID = "weatherView"
                            self.SwitchSegueWith(subID: self.segSubID)
                            self.speakTextWithString(mytext: self.responseSpeech)
                            self.resetConditionalParams()
                        }
                        
                    }else if (self.responseType == "music") {
                        //4) For music responses
                        if (requestType == "album" && self.responseSpeech != nil) {
                            self.resetMusicStuff(string: "album")
                            self.album = Album.init(albumDict: dict)
                            self.segSubID = "playerView"
                            //   if (appDelegate?.auth?.session.isValid())! {
                            //      self.speakTextWithString(mytext: self.responseSpeech)
                            //   }
                            self.checkSessionStatus()
                            self.checkNotification()
                            //self.SwitchSegueWith(subID: self.segSubID)
                            self.resetConditionalParams()
                            
                        }else if (requestType == "track" && self.responseSpeech != nil) {
                            self.resetMusicStuff(string: "track")
                            if let tracks = dict["tracks"] as? [Dictionary<String, Any>] {
                                let trackDict = tracks[0]
                                self.track = Track.init(trackDict: trackDict)
                                self.checkSessionStatus()
                            }
                            self.segSubID = "playerView"
                            
                            //   if (appDelegate?.auth?.session.isValid())! {
                            //      self.speakTextWithString(mytext: self.responseSpeech)
                            //   }
                            
                            self.checkNotification()
                            self.resetConditionalParams()
                            
                            
                        }else if (requestType == "tracks" && self.responseSpeech != nil) {
                            self.resetMusicStuff(string: "tracks")
                            self.artist = Artist.init(artistDict: dict)
                            self.segSubID = "playerView"
                            self.checkSessionStatus()
                            self.checkNotification()
                            //self.SwitchSegueWith(subID: self.segSubID)
                            self.resetConditionalParams()
                            
                        }else {
                            self.speakTextWithString(mytext: "Sorry! I couldn't find anything.")
                        }
                        
                    }else if (self.responseType == "none") {
                        self.speakTextWithString(mytext: self.responseSpeech)
                        self.resetConditionalParams()
                    }
                    
                }else {
                    self.speakTextWithString(mytext: "Sorry! I couldn't find anything.")
                }
            }
            completed()
        }
    }
    
    
    func resetMusicStuff(string: String) {
        if string == "album" {
            self.track = nil
            self.artist = nil
        }else if string == "track" {
            self.album = nil
            self.artist = nil
        }else if string == "tracks" {
            self.album = nil
            self.track = nil
        }
    }
    
    
    func processResponse() {
    
        if self.initiateResponseAnswer == true {
            self.speakTextWithString(mytext: self.responseSpeech)
            self.processRecordingAndAudioSession()
            if self.transcribedText == "yes" {
                self.SwitchSegueWith(subID: self.segSubID)
            }
        }else {
            self.speakTextWithString(mytext: self.responseSpeech)
            self.SwitchSegueWith(subID: self.segSubID)
        }
    
    }
    

    //MARK: Segue methods
    
    func SwitchSegueWith(subID: String) {
    
        if subID == "navigationView" {
            performSegue(withIdentifier: subID, sender: self)
        }else if subID == "placesView" {
            performSegue(withIdentifier: subID, sender: self)
        }else if subID == "playerView" {
            performSegue(withIdentifier: subID, sender: self)
        }else if subID == "weatherView" {
            performSegue(withIdentifier: subID, sender: self)
        }else if subID == "usersView" {
            if tripUsers.count > 0 {
                performSegue(withIdentifier: subID, sender: self)
            }else {
                let alert = UIAlertController.init(title: "No Users!", message: "There are no other users sharing the trip.", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "navigationView" {
            if let viewController = segue.destination as? NavigationVC{
                viewController.navigationObj = DashboardVC.navObj!
            }
        }else if segue.identifier == "placesView" {
            if let viewController = segue.destination as? PlacesVC{
                viewController.places = self.places
            }
        }else if segue.identifier == "playerView" {
            if let viewController = segue.destination as? PlayerVC {
                if (self.album != nil) {
                    viewController.album = self.album
                }else if (self.artist != nil){
                    viewController.artist = self.artist
                }else if (self.track != nil) {
                    viewController.myTrack = self.track
                }
            }
        }else if segue.identifier == "weatherView" {
            if let viewController = segue.destination as? WeatherVC {
                viewController.weatherObj = self.weather
            }
        }else if segue.identifier == "usersView" {
            if let viewController = segue.destination as? UsersVC {
                viewController.users = tripUsers
            }
        }else if segue.identifier == "voiceCallView" {
            if let viewController = segue.destination as? VoiceCallVC {
                viewController.call = sender as! SINCall
                viewController.user = self.remoteUser!
            }
        }else if segue.identifier == "videoCallView" {
            if let viewController = segue.destination as? VideoCallVC {
                viewController.call = sender as! SINCall
                viewController.user = self.remoteUser!
            }
        }

    }
    
    
    @IBAction func navigationButtonPressed(_ sender: Any) {
        
//        if DashboardVC.navObj != nil {
//            self.SwitchSegueWith(subID: "navigationView")
//        }else {
//            self.transcribedText = ""
//            self.processDataFromJSON {
//                
//            }
//        }
        
        if DashboardVC.tripNavObj != nil {
            DashboardVC.navObj = DashboardVC.tripNavObj!
            self.SwitchSegueWith(subID: "navigationView")
        }else {
        
            performSegue(withIdentifier: "searchPlaceView", sender: self)
        }
        
    }
    
    @IBAction func gasStationBtnPressed(_ sender: Any) {
        
        self.transcribedText = "gas station"
        self.processDataFromJSON {
            
        }
        
    }
    
    @IBAction func foodButtonPressed(_ sender: Any) {
        
        self.transcribedText = "restaurants and food"
        self.processDataFromJSON {
            
        }
    }
    
    @IBAction func playerButtonPressed(_ sender: Any) {
        if(isSongPlaying != nil) {
            if(isSongPlaying == true) {
                self.performSegue(withIdentifier: "playerView", sender: self)
            }
        }else {
            self.performSegue(withIdentifier: "searchMusicView", sender: self)
        }
    }
    
    @IBAction func tripUsersPressed(_ sender: Any) {
        self.fetchTripUsers()
        self.SwitchSegueWith(subID: "usersView")
        
    }
    
    
    //MARK: Spotify login manage
    
    
    func checkSessionStatus() {
        print("Current sesion status: \(String(describing: self.auth?.session))")
        // Oh noes, the token has expired, if we have a token refresh service set up, we'll call tat one.
        if (appDelegate?.auth?.hasTokenRefreshService)! {
            self.renewTokenAndShowPlayer()
            return
        }
        
        if appDelegate?.auth?.session == nil {
            
            userDefaults.set(false, forKey: "sessionAvailable")
            self.openLoginPage()
            return
        }
        // Check if it's still valid
        if (appDelegate?.auth?.session.isValid())! {
            // It's still valid, show the player.
            self.showPlayer()
            return
        }else {
            self.openLoginPage()
            return
        }
        
    }
    
    
    func checkNotification() {
        if self.album != nil{
            NotificationCenter.default.addObserver(self, selector: #selector(self.sessionUpdatedNotification), name: NSNotification.Name(rawValue: "sessionUpdated"), object: nil)
        }else if self.track != nil{
            NotificationCenter.default.addObserver(self, selector: #selector(self.sessionUpdatedNotification), name: NSNotification.Name(rawValue: "sessionUpdated"), object: nil)
        }else if self.artist != nil{
            NotificationCenter.default.addObserver(self, selector: #selector(self.sessionUpdatedNotification), name: NSNotification.Name(rawValue: "sessionUpdated"), object: nil)
        }
    }
    
    
    func sessionUpdatedNotification(_ notification: Notification) {
        
        let auth = SPTAuth.defaultInstance()
        if auth!.session != nil && auth!.session.isValid() {
            
            if (self.album != nil || self.artist != nil || self.track != nil) {
                self.showPlayer()
            }
        }
        else {
            print("*** Failed to log in")
        }
    }
    
    
    func showPlayer() {
    
//        self.firstLoad = false
        isSongPlaying = false
        performSegue(withIdentifier: "playerView", sender: self)
        
    }
    
    func renewTokenAndShowPlayer() {
        self.auth?.renewSession(self.auth?.session) { error, session in
            self.auth?.session = session
            if error != nil {
                print("*** Error renewing session: \(String(describing: error))")
                return
            }
            self.showPlayer()
        }
    }
    
    func openLoginPage() {
        let auth = appDelegate?.auth
        
        
        if SPTAuth.supportsApplicationAuthentication() {
            UIApplication.shared.open((auth?.spotifyAppAuthenticationURL())!, options: [:], completionHandler: nil)
            
        } else {
            
            UIApplication.shared.open((self.auth?.spotifyWebAuthenticationURL())!, options: [:]) { (true) in
                if (self.auth?.canHandle(URL.init(string: kSPT_CALLBACK_URL)))! {
                    
                }
            }
            
        }
    }
    
    
    //MARK: Google did sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("Error in google signin: \(error)")
        }else {
            userFname = user.profile.givenName!
            userLname = user.profile.familyName!
            userEmailID = user.profile.email!
            userPicUrl = user.profile.imageURL(withDimension: UInt.min)!
            
            myPreferences.userFname = userFname!
            myPreferences.userLname = userLname!
            myPreferences.userEmailID = userEmailID!
            myPreferences.userPicUrl = userPicUrl!
            
            
            print("Name:\(userFname!) \(userLname!)")
            print("Img URL: \(userPicUrl!)")
            self.processUserWith(id: userEmailID!)
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
                    
                    myPreferences.userSqlID = userSqlID!
                    
                    //This notification will init sinch user.
                    NotificationCenter.default.post(name: NSNotification.Name.init("UserDidLoginNotification"), object: nil, userInfo: ["userID": "\(userSqlID!)"])
                }
                
                
            }
            try con.close()
        }
        catch (let e) {
            print(e)
        }
        
        self.fetchTripUsers()
        
        
    }
    
    
    
    
    //Add midpoint to firebase
    func updateMidPointWith(navigation: Navigation) {
        
        if(userSqlID != nil && tripSqlID != nil) {
            firebaseDataReference = FIRDatabase.database().reference(withPath: "trips/\(tripSqlID!)/midPoint")
            firebaseDataReference.updateChildValues(["userID":userSqlID!,
                                                     "placeName":navigation.destName!,
                                                     "x":navigation.endLoc.coordinate.latitude,
                                                     "y":navigation.endLoc.coordinate.longitude])
            print("Midpoint child added!")
            
        }
        
    }
    
    
    
    
    
    //MARK: Sinch call client delegate
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        self.fetchUserWith(id: call.remoteUserId)
        
        if(call?.details.isVideoOffered)! {
            self.performSegue(withIdentifier: "videoCallView", sender: call!)
        }else {
            self.performSegue(withIdentifier: "voiceCallView", sender: call!)
        }
    }
    
    func client(_ client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
        self.fetchUserWith(id: call.remoteUserId)
        let notification = SINLocalNotification.init()
        notification.alertAction = "Answer"
        notification.alertBody = "Incoming call from \(self.remoteUser.firstName!) \(self.remoteUser.lastName!)"
        return notification
    }
    
    
    //MARK: Text view editing methods
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        displaySpeech.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            displaySpeech.resignFirstResponder()
            self.transcribedText = self.displaySpeech.text
            self.RecordTapped(self.RecordButton!)
            return false
        }
        return true
    }
    
    @IBAction func userHasTouched(_ sender: Any) {
        displaySpeech.resignFirstResponder()
    }
    
    
        
    
}





