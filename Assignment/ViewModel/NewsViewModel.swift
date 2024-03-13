//
//  NewsViewModel.swift
//  Assignment
//
//  Created by Govardhan Singh on 17/02/24.
//

import Foundation
import Combine

class NewsViewModel: ObservableObject {
    @Published var news: [Article] = []
    private var currentPage = 1
    private var pageSize = 20 // Adjust as needed
    private var cancellables = Set<AnyCancellable>()
    private let api = NewsAPI()
    
    var reloadTableView: (() -> Void)?
    
    func fetchNextPage(country:String, isFresh: Bool = false) {
        
        debugPrint("isFresh: \t", isFresh)
        
        if isFresh {
            self.news = []
            self.reloadTableView?()
        }
        
        api.fetchNews(page: isFresh ? 1 : currentPage, pageSize: pageSize, country: country)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] newsArticle in
                
                if isFresh {
                    self?.news = newsArticle
                    self?.currentPage = 1
                } else {
                    self?.news.append(contentsOf: newsArticle)
                    self?.currentPage += 1
                }
                self?.reloadTableView?()
                  })
            .store(in: &cancellables)
    }
    
    func fetchSearchedNews(searchQuery: String, country:String) {
        api.fetchNews(page: 1, pageSize: pageSize, searchQuery: searchQuery, country: country)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] newsArticle in
                self?.news = newsArticle
                    self?.currentPage = 1
                self?.reloadTableView?()
                  })
            .store(in: &cancellables)
    }
}
