//
//  ProfilePictureCell.swift
//  Mangan
//
//  Created by Patrick Leonardus on 21/01/21.
//

import UIKit

class ProfilePictureCell: UITableViewCell {
    
    @IBOutlet weak var profilePictureImage: UIView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileMail: UILabel!
    @IBOutlet weak var profileInitial: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePictureImage.layer.cornerRadius = profilePictureImage.frame.height/2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
