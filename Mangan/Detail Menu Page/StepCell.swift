//
//  StepCell.swift
//  Mangan
//
//  Created by Patrick Leonardus on 18/01/21.
//

import UIKit

class StepCell: UITableViewCell {

    @IBOutlet weak var imageStep: UIView!
    @IBOutlet weak var titleStep: UILabel!
    @IBOutlet weak var stepLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageStep.layer.cornerRadius = self.imageStep.layer.frame.height/2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
