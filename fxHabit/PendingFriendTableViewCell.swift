//
//  PendingFriendTableViewCell.swift
//  fxHabit
//
//  Created by user163799 on 4/23/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit

class PendingFriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func onAcceptButton(_ sender: Any) {
        
    }
    
    @IBAction func onRejectButton(_ sender: Any) {
    
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
