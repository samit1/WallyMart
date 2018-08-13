//
//  ViewController.swift
//  WallyMart
//
//  Created by Sami Taha on 8/13/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController{
    
    /// Search bar
    private lazy var searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        return searchBar
    }()
    
    /// The last searched item
    private var lastSearch : String?
    
    /// The last retrieved item
    private var lastRetrieved = 0
    
    /// Walmart API
    private var walmartAPI = WalmartSearchAPI()
    
    /// Items to display to user
    private var items = [WalmartForSaleItem]()
    
    /// Responsible for showing content to user
    private lazy var itemCollectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: ItemCollectionViewCell.Constants.nibName, bundle: nil), forCellWithReuseIdentifier: ItemCollectionViewCell.Constants.reuseIdentifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSearchbar()
        addSubviews()
        addConstraints()
        view.backgroundColor = UIColor.orange
    }

    private func addSearchbar() {
        navigationItem.titleView = searchBar
    }
    
    private func searchAndRetrieve(query: String) {
        let startAt = query == lastSearch ? lastRetrieved + 1 : 1
        
        walmartAPI.search(query: query, resultStart: startAt) { [weak self] (result) in
            /// Ensure self is still there by the time results return
            guard let sSelf = self else {return}
            switch result {
            case .success(let payload):
                
                /// Guard against race conditions
                guard sSelf.lastSearch == query else {
                    return
                }
                
                /// Append items to array
                sSelf.items += (payload.items)
                
                // MARK: Question
                /// How do I handle paging coming back in the wrong order?
                sSelf.lastRetrieved = max(startAt, sSelf.lastRetrieved)
                sSelf.itemCollectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func addSubviews() {
        view.addSubview(itemCollectionView)
    }
    
    private func addConstraints() {
        let margins = view.safeAreaLayoutGuide
        itemCollectionView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        itemCollectionView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        itemCollectionView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        itemCollectionView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }

}

extension SearchViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else {
            return
        }
        print("Clicked")
        lastSearch = query
        items.removeAll()
        searchAndRetrieve(query: query)
        
    }
}

extension SearchViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count > 0 ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(items.count)
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = itemCollectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.Constants.reuseIdentifier, for: indexPath) as! ItemCollectionViewCell
        
        let saleItem = items[indexPath.row]
        cell.configureCell(price: saleItem.salePrice, imgURL: saleItem.largeImage, title: saleItem.name, description: saleItem.shortDescription)
        return cell
        
    }
}

extension SearchViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let quarterWidth = view.bounds.width * 0.4
        let halfHeight = view.bounds.height
        let maxWidth = min(quarterWidth, halfHeight)
        return CGSize(width: maxWidth, height: maxWidth)
    }
}










