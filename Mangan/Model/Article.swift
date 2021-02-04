//
//  Article.swift
//  Mangan
//
//  Created by Patrick Leonardus on 19/01/21.
//

import Foundation

struct ResultGeneralArticle: Codable {
    let method: String
    let status: Bool
    let results: [GeneralArticle]
}

struct GeneralArticle: Codable {
    let title: String
    let key: String
}

struct ResultListArticle: Codable {
    let method: String
    let status: Bool
    let results: [ListArticle]
}

struct ListArticle: Codable {
    let title: String
    let thumb: String
    let tags: String
    let key: String
}

struct ResultDetailArticle: Codable {
    let method: String
    let status: Bool
    let results: DetailArticle
}

struct DetailArticle: Codable {
    let title: String
    let thumb: String
    let author: String
    let date_published: String
    let description: String
}
