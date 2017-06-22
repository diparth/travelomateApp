//
//  SearchMusicCell.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 5/3/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit

class SearchMusicCell: UITableViewCell {

    
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUIFor(id: Int) {
        if searchedMusic != nil {
            self.titleLabel.text = searchedMusic.titles[id]
            self.typeLabel.text = searchedMusic.types[id]
            self.imgView.image = searchedMusic.imgUrls[id]
            
        }
    }

}
