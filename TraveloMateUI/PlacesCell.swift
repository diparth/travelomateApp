//
//  PlacesCell.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/4/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit
import GooglePlaces

class PlacesCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeRating: UILabel!
    @IBOutlet weak var placeDistance: UILabel!
    
    func configureCell(place: Place) {
        self.nameLabel.text = place.name
        
        //self.placeImage.layer.cornerRadius = 10
        
        if place.rating != nil{
            self.placeRating.text = "\(place.rating!)"
        }else {
            self.placeRating.text = ""
        }
        self.placeDistance.text = place.distance
        self.loadFirstPhotoForPlace(placeID: place.googlePlaceID)
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.placeImage.image = photo;
            }
        })
    }
    
}
