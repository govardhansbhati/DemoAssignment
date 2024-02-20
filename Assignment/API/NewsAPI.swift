//
//  NewsAPI.swift
//  Assignment
//
//  Created by Govardhan Singh on 17/02/24.
//

import Foundation
import Combine

class NewsAPI {
    enum APIError: Error {
        case invalidResponse
        case failedRequest
        case decodingError
    }
    // Please update the apiKey if you're not able load news
    func fetchNews(page: Int, pageSize: Int, searchQuery : String = "all") -> AnyPublisher<[Article], APIError> {
        let url = URL(string: "https://newsapi.org/v2/everything?q=\(searchQuery)&apiKey=9f7a32642e0f43b1a9322e40a9ab14ae&page=\(page)&pageSize=\(pageSize)")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw APIError.failedRequest
                }
                return data
            }
            .decode(type: News.self, decoder: JSONDecoder())
            .map{ $0.articles ?? [] }
            .mapError { _ in APIError.decodingError }
            .eraseToAnyPublisher()
    }
}
