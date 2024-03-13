//
//  ViewController.swift
//  Assignment
//
//  Created by Govardhan Singh on 17/02/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageController : UIPageControl!
    
    var workItemReference: DispatchWorkItem? = nil
    var viewModel = NewsViewModel()
    private let countries = Countries.getCountry()
    private var activityIndicator: UIActivityIndicatorView!
    
    var currentPage: Int? { // Implemented debounce technique
        didSet {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
            
            // Cancel any previous dispatch work item
            workItemReference?.cancel()
            
            // Create a new dispatch work item to fetch news for the current country
            let newsWorkItem = DispatchWorkItem {
                self.viewModel.fetchNextPage(country: self.countries[self.currentPage ?? 0].code ?? "in", isFresh: true)
            }
            
            // Update the reference to the current work item
            workItemReference = newsWorkItem
            
            // Execute the dispatch work item after a delay of 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: newsWorkItem)
            
        }
    }
}
// MARK: - View LifeCycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        self.currentPage = 0
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.reloadTableView = {[weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.view.isUserInteractionEnabled = true
            }
            
        }
    }
    
    private func setUpUI() {
        // Configure collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let cellPadding = (collectionView.bounds.width - 300) / 2
        let carouselLayout = UICollectionViewFlowLayout()
        carouselLayout.scrollDirection = .horizontal
        carouselLayout.itemSize = .init(width: 300, height: collectionView.bounds.height)
        carouselLayout.sectionInset = .init(top: 0, left: cellPadding, bottom: 0, right: cellPadding)
        carouselLayout.minimumLineSpacing  = cellPadding * 2
        collectionView.collectionViewLayout = carouselLayout
        
        // Configure table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.prefetchDataSource = self
        
        // Configure search bar
        searchBar.delegate = self
        
        // Configure ActivityIndicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
    }
    
    private func hideCollectionView() {
        UIView.animate(withDuration: 0.3) {
            self.collectionViewTopConstraint.constant = -(self.collectionView.frame.height + 25)
            self.collectionView.alpha = 0.0
            self.pageController.alpha = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    private func showCollectionView() {
        UIView.animate(withDuration: 0.3) {
            self.collectionViewTopConstraint.constant = 0
            self.collectionView.alpha = 1.0
            self.pageController.alpha = 1.0
            self.view.layoutIfNeeded()
        }
    }
}


// MARK: - Collection View Data Source & Collection View Delegate

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let flagUrl = "https://flagsapi.com/" + (countries[indexPath.item].code?.uppercased() ?? "IN") + "/flat/64.png"
        if let imageUrl = URL(string: flagUrl) {
            cell.imageView.loadImage(fromURL: imageUrl, placeHolderImage: "placeholder")
            cell.countryName.text = countries[indexPath.item].name ?? ""
        }
        cell.imageView.layer.cornerRadius = 25
        cell.imageView.layer.masksToBounds = true
        return cell
    }
}

// MARK: Search Bar Delegate
extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            searchBar.resignFirstResponder()
            self.showCollectionView()
            self.viewModel.fetchNextPage(country: countries[currentPage ?? 0].code ?? "in", isFresh: true)
            return
        }
        viewModel.fetchSearchedNews(searchQuery: searchText, country: countries[currentPage ?? 0].code ?? "in")
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        hideCollectionView()
        return true
    }
}

// MARK: Scroll View Delegate
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if scrollView == tableView {
            if offset > 0 &&  self.collectionViewTopConstraint.constant > -25 {
                hideCollectionView()
            } else if offset <= 0 && self.collectionViewTopConstraint.constant <= -(self.collectionView.frame.height + 25){
                showCollectionView()
            }
        } else if scrollView == collectionView {
            let width = scrollView.frame.size.width
            let currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
            if self.currentPage != currentPage {
                self.currentPage = currentPage
            }
            
            let group = (1...5).map{ $0 * 10 }
            let result = group.enumerated().first(where: {$0.element >= currentPage })
            let page = (result?.offset ?? 0)
        
            pageController.currentPage = page <= 60 ? page : 6
        }
    }
}


// MARK: - Table View Data Source & Table View Delegate

extension  ViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
        let newItem = viewModel.news[indexPath.row]
        cell.textLabel?.text = newItem.title
        cell.textLabel?.numberOfLines = 2
        return cell
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let lastIndexPath = indexPaths.last?.row, lastIndexPath >= viewModel.news.count - 1 else { return }
        viewModel.fetchNextPage(country: countries[currentPage ?? 0].code ?? "in")
    }
}
