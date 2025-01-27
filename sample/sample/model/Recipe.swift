//
//  Recipe.swift
//  sample
//
//  Created by 郑瑞阳 on 1/26/25.
//

import Foundation

struct Recipes: Decodable {
    let recipes: [Recipe]
}

struct Recipe: Decodable{
    let uuid: String
    let cuisine: String
    let name: String
    let photo_url_large: String?
    let photo_url_small: String?
    let source_url: String?
    let youtube_url: String?
}
