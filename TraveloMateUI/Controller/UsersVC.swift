//
//  UsersVC.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/28/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit

class UsersVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SINCallClientDelegate {

    var users = [Users]()
    var client: SINClient!
    var remoteUser: Users!
    @IBOutlet weak var tableView: UITableView!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.client = globalSinchClient!
        self.client.call().delegate = self
        
        // Do any additional setup after loading the view.
    }

    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.client = globalSinchClient!
        self.client.call().delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UsersCell {
            let user = tripUsers[indexPath.row]
            cell.configureCell(user: user)
            cell.videoCallButton.tag = indexPath.row
            cell.voiceCallButton.tag = indexPath.row
            cell.voiceCallButton.addTarget(self, action: #selector(voiceCallPressed), for: .touchUpInside)
            cell.videoCallButton.addTarget(self, action: #selector(videoCallPressed), for: .touchUpInside)
            return cell
        }
        return UsersCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func voiceCallPressed(sender: Any) {
        let btn = sender as? UIButton
        let userID = self.users[(btn?.tag)!].id
        self.remoteUser = tripUsers[(btn?.tag)!]
        print("Voice call Pressed for id: \(userID!)")
        
        if(userID != nil && self.client.isStarted()) {
            let header = ["name":"\(userFname!) \(userLname!)", "propic":"\(userPicUrl!)"]
            let call = self.client.call().callUser(withId: "\(userID!)", headers: header)
            self.performSegue(withIdentifier: "voiceCallView", sender: call!)
        }
        
    }
    
    func videoCallPressed(sender: Any) {
        let btn = sender as? UIButton
        let userID = self.users[(btn?.tag)!].id
        self.remoteUser = tripUsers[(btn?.tag)!]
        print("Video call Pressed for id: \(userID!)")
        
        if(userID != nil && self.client.isStarted()) {
            let header = ["name":"\(userFname!) \(userLname!)", "propic":"\(userPicUrl!)"]
            let call = self.client.call().callUserVideo(withId: "\(userID!)", headers: header)
            self.performSegue(withIdentifier: "videoCallView", sender: call!)
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "voiceCallView" {
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
