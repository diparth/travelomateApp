//
//  Album.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/10/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit
import Foundation
import Alamofire


public class Album {

    var albumID: String!
    var albumURI: String!
    var tracks = [Track]()
    
    init(albumDict: Dictionary<String, Any>) {
        if let id = albumDict["album_id"] as? String {
            self.albumID = id
            self.albumURI = "spotify:album:\(id)"
        }
        if let tracks = albumDict["tracks"] as? [Dictionary<String, Any>] {
            for track in tracks {
                self.tracks.append(Track.init(trackDict: track))
            }
        }
    }
    
    
    func downloadAlbumData() {
        
        //let urlStr = "https://api.spotify.com/v1/albums/3QTVsIyjtbHhXGxwh7H6j3"
    }


}

