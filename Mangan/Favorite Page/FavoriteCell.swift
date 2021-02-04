//
//  FavoriteCell.swift
//  Mangan
//
//  Created by Patrick Leonardus on 22/01/21.
//

import UIKit

class FavoriteCell: UITableViewCell {
    
    
    @IBOutlet weak var favoriteImage: UIImageView!
    @IBOutlet weak var favoriteTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
