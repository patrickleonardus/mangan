//
//  TitleDetailArticleCell.swift
//  Mangan
//
//  Created by Patrick Leonardus on 20/01/21.
//

import UIKit

class TitleDetailArticleCell: UITableViewCell {
    
    @IBOutlet weak var titleArticle: UILabel!
    @IBOutlet weak var authorArticle: UILabel!
    @IBOutlet weak var dateArticle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
