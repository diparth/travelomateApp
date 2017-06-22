//
//  SearchMusicVC.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 5/3/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit
import Alamofire


var searchedMusic: SearchMusic!

class SearchMusicVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var titles = [String]()
    var uris = [String]()
    var imgUrls = [UIImage]()
    var types = [String]()
    
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var cancelButton: UIButton!
    
    var selectedUri: String!
    var searchString: String!
    var auth = appDelegate?.auth

    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.searchTextField.text = ""
        searchedMusic = nil
        self.titles = [String]()
        self.uris = [String]()
        self.imgUrls = [UIImage]()
        self.types = [String]()
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SearchMusicCell {
            cell.updateUIFor(id: indexPath.row)
            return cell
        }
        return SearchMusicCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedUri = self.uris[indexPath.row]
        if isSongPlaying != nil {
            if isSongPlaying == true {
                
            }
        }
        self.checkSessionStatus()
        self.checkNotification()
    }
    
    
    
    func processJSONData(completed: @escaping DownloadComplete) {
        
        if(self.searchString != nil) {
            var urlStr = "https://api.spotify.com/v1/search?q=\(self.searchString!)&type=track,artist,album&market=US&limit=10&offset=\(self.searchString.characters.count)"
            urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let searchUrl = URL.init(string: urlStr)
            
            Alamofire.request(searchUrl!).responseJSON(completionHandler: { (response) in
                let result = response.result
                var albumCount = 0
                var artistCount = 0
                var trackCount = 0
                if let dict = result.value as? Dictionary<String, Any> {
                    //For Albums
                    if let albums = dict["albums"] as? Dictionary<String, Any> {
                        if let items = albums["items"] as? [Dictionary<String, Any>] {
                            for item in items {
                                if let images = item["images"] as? [Dictionary<String, Any>] {
                                    if images.count == 3 {
                                        if let imgStr = images[2]["url"] as? String {
                                            self.imgUrls.append(UIImage.init(data: try! Data.init(contentsOf: URL.init(string: imgStr)!))!)
                                        }else {
                                            self.imgUrls.append(UIImage.init(named: "music")!)
                                        }
                                    }else {
                                        self.imgUrls.append(UIImage.init(named: "music")!)
                                    }
                                }
                                if let name = item["name"] as? String {
                                    self.titles.append(name)
                                }
                                if let type = item["type"] as? String {
                                    self.types.append(type)
                                }
                                if let uri = item["uri"] as? String {
                                    self.uris.append(uri)
                                }
                            }
                        }
                        if let count = albums["total"] as? Int {
                            albumCount = count
                        }
                    }
                    
                    //For Artists
                    if let artists = dict["artists"] as? Dictionary<String, Any> {
                        if let items = artists["items"] as? [Dictionary<String, Any>] {
                            for item in items {
                                if let images = item["images"] as? [Dictionary<String, Any>] {
                                    if images.count == 3 {
                                        if let imgStr = images[2]["url"] as? String {
                                            self.imgUrls.append(UIImage.init(data: try! Data.init(contentsOf: URL.init(string: imgStr)!))!)
                                        }else {
                                            self.imgUrls.append(UIImage.init(named: "music")!)
                                        }
                                    }else {
                                        self.imgUrls.append(UIImage.init(named: "music")!)
                                    }
                                }
                                if let name = item["name"] as? String {
                                    self.titles.append(name)
                                }
                                if let type = item["type"] as? String {
                                    self.types.append(type)
                                }
                                if let uri = item["uri"] as? String {
                                    self.uris.append(uri)
                                }
                            }
                        }
                        if let count = artists["total"] as? Int {
                            artistCount = count
                        }
                    }
                    
                    //For Tracks
                    if let tracks = dict["tracks"] as? Dictionary<String, Any> {
                        if let items = tracks["items"] as? [Dictionary<String, Any>] {
                            for item in items {
                                if let images = item["images"] as? [Dictionary<String, Any>] {
                                    if images.count == 3 {
                                        if let imgStr = images[2]["url"] as? String {
                                            self.imgUrls.append(UIImage.init(data: try! Data.init(contentsOf: URL.init(string: imgStr)!))!)
                                        }else {
                                            self.imgUrls.append(UIImage.init(named: "music")!)
                                        }
                                    }else {
                                        self.imgUrls.append(UIImage.init(named: "music")!)
                                    }
                                }else {
                                    self.imgUrls.append(UIImage.init(named: "music")!)
                                }
                                if let name = item["name"] as? String {
                                    self.titles.append(name)
                                }
                                if let type = item["type"] as? String {
                                    self.types.append(type.capitalized)
                                }
                                if let uri = item["uri"] as? String {
                                    self.uris.append(uri)
                                }
                            }
                        }
                        if let count = tracks["total"] as? Int {
                            trackCount = count
                        }
                    }
                    
                }
                
                if(albumCount == 0 && artistCount == 0 && trackCount == 0) {
                    let alert = UIAlertController.init(title: "Sorry!", message: "No media found for your query.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: { 
                        self.cancelSearchPressed(self.cancelButton!)
                    })
                }
                
                searchedMusic = SearchMusic.init(titles: self.titles, uris: self.uris, imgURLs: self.imgUrls, types: self.types)
                self.tableView.reloadData()
                completed()
            })
            
        }
    }
    
    
    
    func checkSessionStatus() {
        print("Current sesion status: \(String(describing: self.auth?.session))")
        // Oh noes, the token has expired, if we have a token refresh service set up, we'll call tat one.
        if (appDelegate?.auth?.hasTokenRefreshService)! {
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
    
    
    
    func showPlayer() {
        
        //        self.firstLoad = false
        isSongPlaying = false
        performSegue(withIdentifier: "playerView", sender: self)
        
    }
    
    
    func checkNotification() {
        if self.selectedUri != nil{
            NotificationCenter.default.addObserver(self, selector: #selector(self.sessionUpdatedNotification), name: NSNotification.Name(rawValue: "sessionUpdated"), object: nil)
        }
    }
    
    
    func sessionUpdatedNotification(_ notification: Notification) {
        
        let auth = SPTAuth.defaultInstance()
        if auth!.session != nil && auth!.session.isValid() {
            
            if (self.selectedUri != nil) {
                self.showPlayer()
            }
        }
        else {
            print("*** Failed to log in")
        }
    }
    
    
    func openLoginPage() {
        let auth = appDelegate?.auth
        
        
        if SPTAuth.supportsApplicationAuthentication() {
            UIApplication.shared.open((auth?.spotifyAppAuthenticationURL())!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open((self.auth?.spotifyWebAuthenticationURL())!, options: [:]) { (true) in
                if (self.auth?.canHandle(URL.init(string: kSPT_CALLBACK_URL)))! {
                    //self.checkSessionStatus()
                }
            }
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "playerView" && self.selectedUri != nil) {
            if let viewController = segue.destination as? PlayerVC {
                viewController.searchedUri = self.selectedUri!
            }
        }
    }
    
    
    
    @IBAction func cancelSearchPressed(_ sender: Any) {
        self.searchTextField.text = ""
        self.selectedUri = nil
        
        searchedMusic = nil
        self.titles = [String]()
        self.uris = [String]()
        self.imgUrls = [UIImage]()
        self.types = [String]()
        self.tableView.reloadData()
        
        self.searchTextField.resignFirstResponder()
    }
    

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.searchTextField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string == "\n") {
            self.searchString = self.searchTextField.text
            self.searchTextField.resignFirstResponder()
            print("Search text: \(self.searchString!)")
            self.processJSONData {
                print("Inside process JSON")
            }
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchString = self.searchTextField.text
        self.searchTextField.resignFirstResponder()
        print("Search text: \(self.searchString!)")
        self.processJSONData {
            print("Inside process JSON")
        }
        return true
    }
    
    
}








