//
//  SnackBarCustom.swift
//  Mangan
//
//  Created by Patrick Leonardus on 22/01/21.
//

import UIKit
import SnackBar_swift

class SnackBarCustom: SnackBar {
    
    override var style: SnackBarStyle {
        var style = SnackBarStyle()
        style.background = .darkGray
        style.textColor = .white
        return style
    }
}
