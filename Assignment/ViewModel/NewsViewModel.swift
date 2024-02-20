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
    
    func fetchNextPage() {
        api.fetchNews(page: currentPage, pageSize: pageSize)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] newsArticle in
                self?.news.append(contentsOf: newsArticle)
                    self?.currentPage += 1
                self?.reloadTableView?()
                  })
            .store(in: &cancellables)
    }
    
    func fetchSearchedNews(searchQuery: String) {
        api.fetchNews(page: 1, pageSize: pageSize, searchQuery: searchQuery)
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
