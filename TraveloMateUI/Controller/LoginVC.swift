//
//  ViewController.swift
//  SpotifyTest
//
//  Created by Seth Rininger on 10/27/16.
//  Copyright © 2016 Seth Rininger. All rights reserved.
//

import UIKit
import WebKit
import Foundation

class LoginVC: UIViewController, SPTStoreControllerDelegate {
    
    
    //Outlets
    @IBOutlet weak var loginButton: UIButton!
    
    
    //Variables
    
    var authViewController: UIViewController?
    var firstLoad: Bool!
    var auth = SPTAuth.defaultInstance()!
    var session: SPTSession!
    var player: SPTAudioStreamingController!
    var loginURL: URL!
    var track: Track!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Song name is: \(self.track.trackName!)")
        loginURL = auth.spotifyWebAuthenticationURL()
        NotificationCenter.default.addObserver(self, selector: #selector(self.sessionUpdatedNotification), name: NSNotification.Name(rawValue: "sessionUpdated"), object: nil)
        self.firstLoad = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let auth = SPTAuth.defaultInstance()
        // Uncomment to turn off native/SSO/flip-flop login flow
        //auth.allowNativeLogin = NO;
        // Check if we have a token at all
        if auth!.session == nil {
            return
        }
        // Check if it's still valid
        if auth!.session.isValid() && self.firstLoad {
            // It's still valid, show the player.
            self.showPlayer()
            return
        }
        // Oh noes, the token has expired, if we have a token refresh service set up, we'll call tat one.
        if auth!.hasTokenRefreshService {
            self.renewTokenAndShowPlayer()
            return
        }
        // Else, just show login dialog
    }

    
    
//    func getAuthViewController(withURL url: URL) -> UIViewController {
//        
//        return UINavigationController(rootViewController: webView)
//    }
    
    func sessionUpdatedNotification(_ notification: Notification) {
        let auth = SPTAuth.defaultInstance()
        self.presentedViewController?.dismiss(animated: true, completion: { _ in })
        if auth!.session != nil && auth!.session.isValid() {
            self.showPlayer()
        }
        else {
            print("*** Failed to log in")
        }
    }
    
    func showPlayer() {
        self.firstLoad = false
        self.loginButton.isHidden = true
        self.loginButton.isEnabled = false
        self.performSegue(withIdentifier: "playerView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PlayerVC {
            viewController.myTrack = self.track
        }
    }
    
    internal func productViewControllerDidFinish(_ viewController: SPTStoreViewController) {
        viewController.dismiss(animated: true, completion: { _ in })
    }
    
    func openLoginPage() {
        
        if SPTAuth.supportsApplicationAuthentication() {
            UIApplication.shared.open(self.auth.spotifyAppAuthenticationURL(), options: [:], completionHandler: nil)
        } else {
            
            UIApplication.shared.open(self.loginURL!, options: [:]) { (true) in
                if self.auth.canHandle(self.auth.redirectURL) {
                    
                }
            }
            
//            self.authViewController = self.getAuthViewController(withURL: SPTAuth.defaultInstance().spotifyWebAuthenticationURL())
//            self.definesPresentationContext = true
//            self.present(self.authViewController!, animated: true, completion: { _ in })
            
        }
    }
    
    func renewTokenAndShowPlayer() {
        SPTAuth.defaultInstance().renewSession(SPTAuth.defaultInstance().session) { error, session in
            SPTAuth.defaultInstance().session = session
            if error != nil {
                print("*** Error renewing session: \(String(describing: error))")
                return
            }
            self.showPlayer()
        }
    }
    
    @IBAction func loginButtonWasPressed(_ sender: SPTConnectButton) {
        self.openLoginPage()
    }

}

