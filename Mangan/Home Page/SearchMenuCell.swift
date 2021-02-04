//
//  SearchMenuCell.swift
//  Mangan
//
//  Created by Patrick Leonardus on 15/01/21.
//

import UIKit

class SearchMenuCell: UITableViewCell {

    @IBOutlet weak var imageRecipe: UIImageView!
    @IBOutlet weak var titleRecipe: UILabel!
    @IBOutlet weak var timeRecipe: UILabel!
    @IBOutlet weak var difficultyRecipe: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
