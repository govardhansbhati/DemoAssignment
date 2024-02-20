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
    
    var viewModel = NewsViewModel()
    let imageCache = NSCache<NSString, UIImage>()
    
}
// MARK: - View LifeCycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        
        viewModel.fetchNextPage()
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.reloadTableView = {[weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func setUpUI() {
        // Configure collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        
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

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.news.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let article = viewModel.news[indexPath.item]
        if let imageUrlString = article.urlToImage, let imageUrl = URL(string: imageUrlString) {
            if let cachedImage = imageCache.object(forKey: imageUrlString as NSString) {
                cell.imageView.image = cachedImage
            } else {
                DispatchQueue.global().async {
                    if let imageData = try? Data(contentsOf: imageUrl), let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.imageCache.setObject(image, forKey: imageUrlString as NSString)
                            if let cellToUpdate = collectionView.cellForItem(at: indexPath) as? ImageCell {
                                cellToUpdate.imageView.image = image
                            }
                        }
                    }
                }
            }
            
            if indexPath.item == viewModel.news.count - 1 {
                viewModel.fetchNextPage()
            }
        }
        cell.imageView.layer.cornerRadius = 25
        cell.imageView.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let lastIndexPath = indexPaths.last?.row, lastIndexPath >= viewModel.news.count - 1 else { return }
        viewModel.fetchNextPage()
    }
}

// MARK: Search Bar Delegate
extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            searchBar.resignFirstResponder()
            self.viewModel.fetchNextPage()
            return
        }
        viewModel.fetchSearchedNews(searchQuery: searchText)
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
            if offset > 0 {
                hideCollectionView()
            }
        } else if scrollView == collectionView {
            let width = scrollView.frame.size.width
            let currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
            pageController.currentPage = currentPage == 0 ? 0 : (currentPage == viewModel.news.count ? 2 : 1)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            showCollectionView()
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
        viewModel.fetchNextPage()
    }
}
