//
//  SearchMusic.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 5/3/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import Foundation


public class SearchMusic {
    
    var titles = [String]()
    var uris = [String]()
    var imgUrls = [UIImage]()
    var types = [String]()
    
    init(titles:[String], uris:[String], imgURLs:[UIImage], types:[String]) {
        self.titles = titles
        self.uris = uris
        self.imgUrls = imgURLs
        self.types = types
    }
    
}
