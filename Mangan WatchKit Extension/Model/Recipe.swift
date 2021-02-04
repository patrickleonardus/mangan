//
//  Recipe.swift
//  Mangan WatchKit Extension
//
//  Created by Patrick Leonardus on 26/01/21.
//

import UIKit

struct Recipe: Codable {
    
    let method: String
    let status: Bool
    let results: Result
    
}

struct Result: Codable {
    let title: String
    let thumb: String?
    let servings: String
    let times: String
    let dificulty: String
    let author: Author
    let desc: String
    let needItem: [NeedItem]
    let ingredient: [String]
    let step: [String]
}

struct Author: Codable {
    let user: String
    let datePublished: String
}

struct NeedItem: Codable {
    let item_name: String
    let thumb_item: String
}
