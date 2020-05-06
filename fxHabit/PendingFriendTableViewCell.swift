//
//  PendingFriendTableViewCell.swift
//  fxHabit
//
//  Created by user163799 on 4/23/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit

class PendingFriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendRequestLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        acceptButton.layer.cornerRadius = 4
        rejectButton.layer.cornerRadius = 4
        acceptButton.isHidden = true
        rejectButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
