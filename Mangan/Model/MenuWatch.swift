//
//  MenuWatch.swift
//  Mangan
//
//  Created by Patrick Leonardus on 25/01/21.
//

import Foundation

struct MenuWatch {
    let imageUrl: String
    let menuUrl: String
    let title: String
    
    init(imageUrl: String, menuUrl: String, title: String) {
        self.imageUrl = imageUrl
        self.menuUrl = menuUrl
        self.title = title
    }
}
