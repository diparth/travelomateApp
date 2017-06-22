//
//  Placevc.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/4/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import Firebase
import CoreLocation


class PlacesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var places: [Place]!
    var navigation: Navigation!
    var destLoc: CLLocation!
    var navURL = ""
    var placeName: String!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
//    @IBAction func cancelPress(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PlacesCell {
            let place = places[indexPath.row]
            cell.configureCell(place: place)
            return cell
        }
        
        return PlacesCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.destLoc = CLLocation.init(latitude: self.places[indexPath.row].location.coordinate.latitude, longitude: self.places[indexPath.row].location.coordinate.longitude)
        self.placeName = self.places[indexPath.row].name
        self.navURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(DashboardVC.currentLoc.coordinate.latitude),\(DashboardVC.currentLoc.coordinate.longitude)&destination=\(self.destLoc.coordinate.latitude),\(self.destLoc.coordinate.longitude)&key=\(GMS_PLACE_KEY)"
        print("----Nav URL: \(self.navURL)")
        self.processJSONData {
            print("getting JSON Data")
        }
        
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? NavigationVC {
            viewController.navigationObj = self.navigation
        }
    }
    
    func processJSONData(completed: @escaping DownloadComplete) {
    
        let urlstr = self.navURL
        let url = URL.init(string: urlstr)
        print("\(url!)")
        
        Alamofire.request(url!).responseJSON { (response) in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, Any> {
                if let routes = dict["routes"] as? [Dictionary<String, Any>] {
                    if let legs = routes[0]["legs"] as? [Dictionary<String, Any>] {
                        self.navigation = Navigation.init(myData: legs[0], name: self.placeName!)
                        if self.navigation != nil {
                            DashboardVC.navObj = self.navigation
                            self.updateMidPointWith(navigation: self.navigation)
                            self.performSegue(withIdentifier: "navigationView", sender: self)
                        }
                    }
                }
            }
            completed()
        }
        
    }

    
    
    //Update mispoint to Firebase
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
    
    
    
    
}

/*
 

 Alamofire.request(url!).responseJSON { (response) in
 let result = response.result
 
 if let dict = result.value as? Dictionary<String, Any> {
 if let routes = dict["routes"] as? [Dictionary<String, Any>] {
 if let legs = routes[0]["legs"] as? [Dictionary<String, Any>] {
 self.navigation = Navigation.init(myData: legs[0])
 }
 }
 }
 completed()
 }
*/




/*
 
 URLSession.shared.dataTask(with: url!) { (data, response, error) in
 if error != nil {
 print(error!)
 } else {
 do {
 print("\(response)")
 let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
 print("\(parsedData)")
 //
 //                    if let dict = result.value as? Dictionary<String, Any> {
 //                        if let routes = dict["routes"] as? [Dictionary<String, Any>] {
 //                            if let legs = routes[0]["legs"] as? [Dictionary<String, Any>] {
 //                                self.navigation = Navigation.init(myData: legs[0])
 //                            }
 //                        }
 //                    }
 self.performSegue(withIdentifier: "navigationView", sender: self)
 } catch let error as NSError {
 print(error)
 }
 }
 }.resume()
 
 */

