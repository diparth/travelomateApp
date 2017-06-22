//
//  AppReq.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/22/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit


class Preferences: NSObject, NSCoding {
    


    var userEmailID: String!
    var userFname: String!
    var userLname: String!
    var userPicUrl: URL!
    
    var userSqlID: Int!
    var tripSqlID: Int!
    
    var tripSharedUsers = [Users]()

    var tripEndLocation: CLLocation!
    var tripDestName: String!

    
    var isUserAllowedToUpdateLoc = false

    
    var ifTripReceived: Bool!
    
    
    override init() {
        
        self.userSqlID = Int()
        self.userEmailID = String()
        self.userFname = String()
        self.userLname = String()
        self.userPicUrl = URL.init(string: "http://s26388.storage.proboards.com/5606388/i/fiVAHBwCNTN9EOa8FrNS.png")
        self.tripSqlID = Int()
        self.tripEndLocation = CLLocation()
        self.tripDestName = String()
        self.isUserAllowedToUpdateLoc = false
        self.tripSharedUsers = [Users]()
        
    }
    
    init(pref: Preferences) {
        self.userSqlID = pref.userSqlID!
        self.userEmailID = pref.userEmailID!
        self.userFname = pref.userFname!
        self.userLname = pref.userLname!
        self.userPicUrl = pref.userPicUrl!
        self.tripSqlID = pref.tripSqlID!
        self.tripEndLocation = pref.tripEndLocation!
        self.tripDestName = pref.tripDestName!
        self.isUserAllowedToUpdateLoc = pref.isUserAllowedToUpdateLoc
        self.tripSharedUsers = pref.tripSharedUsers
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.userSqlID = aDecoder.decodeObject(forKey: "uid") as! Int
        self.userEmailID = aDecoder.decodeObject(forKey: "uemail") as! String
        self.userFname = aDecoder.decodeObject(forKey: "ufname") as! String
        self.userLname = aDecoder.decodeObject(forKey: "ulname") as! String
        self.userPicUrl = aDecoder.decodeObject(forKey: "upic") as! URL
        self.tripSqlID = aDecoder.decodeObject(forKey: "tripid") as! Int
        self.tripEndLocation = aDecoder.decodeObject(forKey: "tripendloc") as! CLLocation
        self.tripDestName = aDecoder.decodeObject(forKey: "tripdestname") as! String
        self.isUserAllowedToUpdateLoc = aDecoder.decodeBool(forKey: "isUserAllowedToUpdateLoc")
        self.tripSharedUsers = aDecoder.decodeObject(forKey: "tripusers") as! [Users]
        
    }
    
    
    func encode(with aCoder: NSCoder) {
        //Int
        aCoder.encode(userSqlID, forKey: "uid")
        aCoder.encode(tripSqlID, forKey: "tripid")
        
        
        //String
        aCoder.encode(userEmailID, forKey: "uemail")
        aCoder.encode(userFname, forKey: "ufname")
        aCoder.encode(userLname, forKey: "ulname")
        aCoder.encode(userPicUrl, forKey: "upic")
        aCoder.encode(tripEndLocation, forKey: "tripendloc")
        aCoder.encode(tripDestName, forKey: "tripdestname")
        aCoder.encode(isUserAllowedToUpdateLoc, forKey: "isUserAllowedToUpdateLoc")
        aCoder.encode(tripSharedUsers, forKey: "tripusers")

    }
    
    
    
}







