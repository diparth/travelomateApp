//
//  SearchPlaceVC.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/23/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire

class SearchPlaceVC: UIViewController, GMSAutocompleteResultsViewControllerDelegate {

    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    var navURL = ""
    var navigation: Navigation!
    var placeName: String!
    
    @IBOutlet weak var startNavigationButton: UIButton!
    @IBOutlet weak var placeView: UIView!
    @IBOutlet weak var placeNameLabel: UITextView!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        self.placeView.isHidden = true
        
        self.placeView.layer.cornerRadius = 15
        self.startNavigationButton.layer.cornerRadius = 15
        
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }


    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Do something with the selected place.
        self.placeName = place.name
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        print("Place Id: \(place.placeID)")
        
        self.navURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(DashboardVC.currentLoc.coordinate.latitude),\(DashboardVC.currentLoc.coordinate.longitude)&destination=\(place.coordinate.latitude),\(place.coordinate.longitude)&key=\(GMS_PLACE_KEY)"
        
        print("----Nav URL: \(self.navURL)")
        self.processJSONData {
            print("getting JSON Data")
        }
        
    }
    
    func updatePlaceUI() {
        self.placeView.isHidden = false
        self.placeNameLabel.text = self.placeName!
        
    }
    
    
    func switchSegue() {
        
        self.performSegue(withIdentifier: "navigationView", sender: self)
    }

    @IBAction func startNavigationPressed(_ sender: Any) {
        self.placeView.isHidden = true
        self.switchSegue()
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
    
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        //UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
                        
                    }
                }
            }
            
            completed()
        }
        self.updatePlaceUI()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? NavigationVC {
            viewController.navigationObj = self.navigation!
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
