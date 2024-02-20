//
//  News.swift
//  Assignment
//
//  Created by Govardhan Singh on 17/02/24.
//

import Foundation

struct Article: Codable {
    let title: String?
    let description: String?
    let urlToImage: String?
}

struct News: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?
}
