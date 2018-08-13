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
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout.init())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSearchbar()
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
                itemCollectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    

}

extension SearchViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else {
            return
        }
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
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
}








