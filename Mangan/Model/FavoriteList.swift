//
//  FavoriteList.swift
//  Mangan
//
//  Created by Patrick Leonardus on 22/01/21.
//

import Foundation
import CoreData

struct MenuFavoriteList {
    let imageUrl: String
    let key: String
    let title: String
    
    init(imageUrl: String, key: String, title: String) {
        self.imageUrl = imageUrl
        self.key = key
        self.title = title
    }
}

struct ArticleFavoriteList {
    let imageUrl: String
    let key: String
    let title: String
    let tag: String
    
    init(imageUrl: String, key: String, title: String, tag: String) {
        self.imageUrl = imageUrl
        self.key = key
        self.title = title
        self.tag = tag
    }
}
