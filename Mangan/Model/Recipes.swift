//
//  Recipes.swift
//  Mangan
//
//  Created by Patrick Leonardus on 14/01/21.
//

import Foundation

class Recipes: Decodable {
    
    let method: String?
    let status: Bool?
    let results: [Results]?
    
}

class Results: Decodable {
    let title: String?
    let thumb: String?
    let key: String?
    let times: String?
    let portion: String?
    let dificulty: String?
}

class SearchRecipes: Decodable {
    
    let method: String?
    let status: Bool?
    let results: [SearchResults]?
    
}

class SearchResults: Decodable {
    let title: String?
    let thumb: String?
    let key: String?
    let times: String?
    let serving: String?
    let difficulty: String?
}

class DetailRecipe: Codable {
    
    let method: String
    let status: Bool
    let results: DetailResult
    
}

class DetailResult: Codable {
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

class Author: Codable {
    let user: String
    let datePublished: String
}

class NeedItem: Codable {
    let item_name: String
    let thumb_item: String
}

struct MenuResult: Codable {
    let method: String
    let status: Bool
    let results: [Menu]
}

struct Menu: Codable{
    let category: String
    let url: String
    let key: String
}
