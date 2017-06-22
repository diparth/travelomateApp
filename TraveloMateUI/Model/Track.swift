//
//  Track.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/10/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit
import Foundation


public class Track {

    var artists = [String]()
    var apiUrlString : String!
    var trackName: String!
    var trackID: String!
    var trackNumber: Int!
    var trackURI: String!
    
    init(dictData: Dictionary<String, Any>) {
    
        if let artists = dictData["artists"] as? [Dictionary<String, Any>] {
            for artist in artists {
                if let artistName = artist["name"] as? String {
                    self.artists.append(artistName)
                }
            }
        }
        if let href = dictData["href"] as? String {
            self.apiUrlString = href
        }
        if let name = dictData["name"] as? String {
            self.trackName = name
        }
        if let id = dictData["id"] as? String {
            self.trackID = id
        }
        if let trkNum = dictData["track_number"] as? Int {
            self.trackNumber = trkNum
        }
        if let uri = dictData["uri"] as? String {
            self.trackURI = uri
        }
    }
    
    init(trackDict: Dictionary<String, Any>) {
        if let id = trackDict["track_id"] as? String {
            self.trackID = id
            self.trackURI = "spotify:track:\(id)"
        }
        if let name = trackDict["track_name"] as? String {
            self.trackName = name
        }
    }
    
}
