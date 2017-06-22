//
//  UsersCell.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/29/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit

class UsersCell: UITableViewCell {

    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var voiceCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
    
    
    func configureCell(user: Users) {
        self.userNameLabel.text = "\(user.firstName!) \(user.lastName!)"
        self.userIdLabel.text = "Caller id: \(user.id!)"
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
        self.userImage.clipsToBounds = true
        DispatchQueue.main.async {
            self.userImage.image = UIImage.init(data: try! Data.init(contentsOf: user.picUrl))
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
