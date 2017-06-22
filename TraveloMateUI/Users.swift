//
//  Users.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/24/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import Foundation
import UIKit

public class Users: NSObject, NSCoding {

    
    var id: Int!
    var firstName: String!
    var lastName: String!
    var emailID: String!
    var picUrl: URL!
    
    init(id: Int, fName: String, lName: String, email: String, picStr: String) {
        self.id = id
        self.firstName = fName
        self.lastName = lName
        self.emailID = email
        self.picUrl = URL.init(string: picStr)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "uid") as! Int
        self.firstName = aDecoder.decodeObject(forKey: "fname") as! String
        self.lastName = aDecoder.decodeObject(forKey: "lname") as! String
        self.emailID = aDecoder.decodeObject(forKey: "emailid") as! String
        self.picUrl = aDecoder.decodeObject(forKey: "picurl") as! URL
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "uid")
        aCoder.encode(firstName, forKey: "fname")
        aCoder.encode(lastName, forKey: "lname")
        aCoder.encode(emailID, forKey: "emailid")
        aCoder.encode(picUrl, forKey: "picurl")
    }
    
    
    
    
}
