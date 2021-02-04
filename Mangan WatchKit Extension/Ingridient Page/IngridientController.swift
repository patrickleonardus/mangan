//
//  IngridientController.swift
//  Mangan WatchKit Extension
//
//  Created by Patrick Leonardus on 26/01/21.
//

import UIKit
import WatchKit

class IngridientController: WKInterfaceController {
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    var ingridients: [String]?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.ingridients = context as? [String]
        if let count = self.ingridients?.count {
            tableView.setNumberOfRows(count, withRowType: "ingridient_cell")
            for index in 0...count-1 {
                if let cell = tableView.rowController(at: index) as? IngridientCell {
                    let ingridient = ingridients?[index]
                    cell.noLabel.setText("\(index+1).")
                    cell.label.setText(ingridient)
                }
            }
        }
    }
    
    
}


