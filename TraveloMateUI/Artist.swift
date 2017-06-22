//
//  Artist.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/15/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit
import Foundation



public class Artist {
    
    var artistID: String!
    var artistURI: String!
    var tracks = [Track]()
    
    init(artistDict: Dictionary<String, Any>) {
        if let id = artistDict["artist_id"] as? String {
            self.artistID = id
            self.artistURI = "spotify:artist:\(id)"
        }
        if let tracks = artistDict["tracks"] as? [Dictionary<String, Any>] {
            for track in tracks {
                self.tracks.append(Track.init(trackDict: track))
            }
        }
    }
    
    
}
