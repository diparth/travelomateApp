//
//  TempCode.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/12/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import Foundation

//          if let track = result as? SPTTrack {
//                let imageURL = track.album.largestCover.imageURL
//                if imageURL == nil {
//                    print("Album \(track.album) doesn't have any images!")
//                    self.coverView.image = nil
//                    self.coverView2.image = nil
//                    return
//                }
//                // Pop over to a background queue to load the image over the network.
//
//                DispatchQueue.main.sync {
//                    do {
//                        let imageData = try Data(contentsOf: imageURL!, options: [])
//                        let image = UIImage(data: imageData)
//                        // …and back to the main queue to display the image.
//                        DispatchQueue.main.sync {
//                            self.spinner.stopAnimating()
//                            self.coverView.image = image
//                            if image == nil {
//                                print("Couldn't load cover image with error: \(error)")
//                                return
//                            }
//                        }
//                        // Also generate a blurry version for the background
//                        let blurred = self.applyBlur(on: image!, withRadius: 10.0)
//                        DispatchQueue.main.sync {
//                            self.coverView2.image = blurred
//                        }
//
//                    } catch let error {
//                        print(error.localizedDescription)
//                    }
//                }
//            }











//For Mid point checking

//if(userSqlID != nil && tripSqlID != nil) {
//
//                firebaseDataReference = FIRDatabase.database().reference(withPath: "trips/\(tripSqlID!)/midPoint/")
//                let refHandle = firebaseDataReference.observe(.value, with: { (snapshot) in
//                    if let resultDict = snapshot.value as? Dictionary<String, Any> {
//                        if let placename = resultDict["placeName"] as? String {
//                            midPointPlaceName = placename
//                        }
//                        if let midLat = resultDict["x"] as? Double {
//                            if let midLog = resultDict["y"] as? Double {
//                                midPointLocation = CLLocation.init(latitude: midLat, longitude: midLog)
//                            }
//                        }
//                    }
//                    if(midPointPlaceName != "" && midPointLocation.coordinate.latitude != 0 && midPointLocation.coordinate.longitude != 0) {
//                        let alert = UIAlertController.init(title: "", message: "Your friend is going to \(midPointPlaceName!). Would you like to join?", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction.init(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
//                        alert.addAction(UIAlertAction.init(title: "Yes!", style: UIAlertActionStyle.default, handler: { (action) in
//                            self.navigateToMidpoint()
//                        }))
//
//                        self.present(alert, animated: true, completion: { _ in })
//                        if(self.navigationObj != nil) {
//                            self.processJSONData {
//                                print("Inside process JSON.")
//                            }
//                        }
//                    }
//                })
//                print("refHandle: \(refHandle)")
//
//            }
