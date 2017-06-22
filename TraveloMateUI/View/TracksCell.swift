//
//  TracksCell.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/10/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit

class TracksCell: UITableViewCell {

    
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songAlbumName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(track: Track) {
    
        if track.trackName != nil {
            self.songName.text = track.trackName
        }else {
            self.songName.text = "Unknown"
        }
        self.songAlbumName.text = ""
    }

}
