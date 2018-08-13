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
        searchBar.placeholder = "Search for something!"
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
    
    
    // QUESTION:
    /// This will get called a billion times. Is there a better way to do this? 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }

    /// Adds a search bar to the navigation title view
    private func addSearchbar() {
        navigationItem.titleView = searchBar
    }
    
    /// Calls the walmartAPI to search for parameter
    private func searchAndRetrieve(query: String, startAt: Int) {
    
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
                
                
                // MARK: Question
                /// Any recommendations on how to I should only reload the new data that comes in instead of reloading the whole table? The following code was making me crash
                /*
                if prevCount == 0 {
                    sSelf.itemCollectionView.reloadData()
                } else {
                   let updatePaths = sSelf.createIndexPaths(sectionStart: 0, sectionEnd: 0, rowStart: prevCount, rowEnd: newCount - 1)
                   print(updatePaths)
                   sSelf.itemCollectionView.reloadItems(at: updatePaths)
                   }
                 */
                sSelf.itemCollectionView.reloadData()

                
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// Adds subviews
    private func addSubviews() {
        view.addSubview(itemCollectionView)
    }
    
    
    /// Adds constraints
    private func addConstraints() {
        let margins = view.safeAreaLayoutGuide
        itemCollectionView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        itemCollectionView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        itemCollectionView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        itemCollectionView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }
    
    /// Handles paging the paging for the next search results
    private func pageResults() {
        guard let lastSearch = lastSearch else {
            return
        }
        searchAndRetrieve(query: lastSearch, startAt: lastRetrieved + 1)
    }
    
    /// Creates index paths for specified start and end positions
    private func createIndexPaths(sectionStart: Int, sectionEnd: Int, rowStart: Int, rowEnd: Int) -> [IndexPath] {
        var paths = [IndexPath]()
        
        for section in 0...sectionEnd where section >= sectionStart {
            for row in 0...rowEnd where row >= rowStart {
                let indexPath = IndexPath(row: row, section: section)
                paths.append(indexPath)
            }
        }
        
        return paths
    }
    
    
  
}

extension SearchViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty, query != lastSearch else {
            return
        }
        print("Clicked")
        lastSearch = query
        lastRetrieved = 1
        items.removeAll()
        searchBar.resignFirstResponder()
        searchAndRetrieve(query: query, startAt: lastRetrieved)
        
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
        cell.configureCell(price: saleItem.salePrice, imgURL: saleItem.largeImage)
        
        if indexPath.row == items.count - 1 {
            print(indexPath)
            pageResults()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        <#code#>
    }
}

extension SearchViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let quarterWidth = view.bounds.width * 0.4
        let halfHeight = view.bounds.height / 2
        let maxWidth = min(quarterWidth, halfHeight)
        return CGSize(width: maxWidth, height: halfHeight)
    }
}













