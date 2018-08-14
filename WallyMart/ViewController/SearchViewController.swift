//
//  ViewController.swift
//  WallyMart
//
//  Created by Sami Taha on 8/13/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import UIKit

/*
 Changes from last session:
 1. All delegation is handled lazily so datasource/delegate can be assigned to self and encapsulated
 2. Subviews added into one method, constraint addition called from viewDidLoad instead of loadView
 3. Added paging and search functionality
 4. Added footer activity indicator
 5. Moved lazy fetching of images into the collectionviewcelll 
 
 
 */


class SearchViewController: UIViewController {
    
    /// Search bar
    private lazy var searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search for something!"
        return searchBar
    }()
    
    /// The last searched item
    private var lastSearch : String?
    
    /// Items to display to user
    private var items = [WalmartForSaleItem]() {
        didSet {
            itemCollectionView.reloadData()
        }
    }
    
    /// A helper view to notify the user that they can perform searches
    private var searchMe = UIView() {
        didSet {
            searchMe.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    /// State of the view
    private var viewState = ViewState.noResults {
        didSet {
            setViewForState()
        }
    }
    
    /// Store which holds items for sale
    private lazy var saleStore :  WalmartForSaleItemStore = {
        let store = WalmartForSaleItemStore()
        store.delegate = self
        return store
    }()
    
    /// Activity indicator shown at the center of the screen when a search is being performed
    private var activityIndicator : UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.black
        return activityIndicator
    }()
    
    /// Responsible for showing content to user
    private lazy var itemCollectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: ItemCollectionViewCell.Constants.nibName, bundle: nil), forCellWithReuseIdentifier: ItemCollectionViewCell.Constants.reuseIdentifier)
        collectionView.register(UINib(nibName: AnimationFooterCollectionReusableView.Constants.nibName, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: AnimationFooterCollectionReusableView.Constants.reuseIdentifer)
        return collectionView
    }()
    
    /// Footer view for itemCollectionView
    private lazy var footerView : AnimationFooterCollectionReusableView = {
        var footerView = AnimationFooterCollectionReusableView()
        footerView.translatesAutoresizingMaskIntoConstraints = false
        return footerView
    }()
    
    /// State of the view
    enum ViewState {
        case noResults
        case populated
        case searching
        case paging
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSearchbar()
        addSubviews()
        addConstraints()
        view.backgroundColor = UIColor.orange
    }
    
    // MARK: QUESTION: My views end up overlaying when I transition. Why? The view debugger shows it differently. I've created a stackview and the label has the highest compression resistance 
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        itemCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    // MARK: QUESTION: Is this the correct method to resign first responder? Recognize I don't want to use scrollviewdidscroll
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        searchBar.resignFirstResponder()
    }
    
    
    /// Adds a search bar to the navigation title view
    private func addSearchbar() {
        navigationItem.titleView = searchBar
    }
    
    /// Changes what is being presented to the user depending on the `viewState`
    private func setViewForState() {
        switch viewState {
        case .noResults:
            searchMe.isHidden = false
            activityIndicator.stopAnimating()
        case .paging:
            searchMe.isHidden = true
            activityIndicator.stopAnimating()
        case .populated:
            searchMe.isHidden = true
            activityIndicator.stopAnimating()
        case .searching:
            searchMe.isHidden = true
            activityIndicator.startAnimating()
        }
    }
    
    /// Creates a SearchMe view from a xib
    private func createSearchMe() -> UIView? {
        if let searchMe = Bundle.main.loadNibNamed("SearchMe", owner: self, options: nil)?.first as? UIView {
            return searchMe
        } else {
            print("SearchMe.xib not found")
            return nil
        }
    }
    
    /// Adds subviews
    private func addSubviews() {
        view.addSubview(itemCollectionView)
        if let view = createSearchMe() {
            itemCollectionView.addSubview(view)
            searchMe = view
        }
        
        itemCollectionView.addSubview(activityIndicator)
    }
    
    
    /// Adds constraints
    private func addConstraints() {
        let margins = view.safeAreaLayoutGuide
        itemCollectionView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        itemCollectionView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        itemCollectionView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        itemCollectionView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        
        searchMe.centerXAnchor.constraint(equalTo: itemCollectionView.centerXAnchor).isActive = true
        searchMe.centerYAnchor.constraint(equalTo: itemCollectionView.centerYAnchor).isActive = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: itemCollectionView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: itemCollectionView.centerYAnchor).isActive = true
        
    }
    
    /// Handles paging the paging for the next search results
    private func pageResults() {
        viewState = .paging
        saleStore.requestNextPage()
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
    
        /// Reset what was last searched
        lastSearch = query
        
        
        /// Resigns keyboard
        searchBar.resignFirstResponder()
        
        /// Changes `viewState` to the .searching state
        viewState = .searching
        
        /// Performs a search
        saleStore.requestNewItems(query: query)
        
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
        
        let cell = itemCollectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.Constants.reuseIdentifier, for: indexPath) as! ItemCollectionViewCell
        
        let saleItem = items[indexPath.row]
        cell.configureCell(price: saleItem.salePrice, imgURL: saleItem.largeImage)
        
        
        /// If we are at the last item in our array, page for next set of data
        if indexPath.row == items.count - 1 {
            print(indexPath)
            pageResults()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        /// Create a footer view
        if kind == UICollectionElementKindSectionFooter {
            let aFooter = itemCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AnimationFooterCollectionReusableView.Constants.reuseIdentifer, for: indexPath) as! AnimationFooterCollectionReusableView
            self.footerView = aFooter
            footerView.backgroundColor = UIColor.clear
            return aFooter
        } else {
            let header = itemCollectionView.dequeueReusableCell(withReuseIdentifier: AnimationFooterCollectionReusableView.Constants.reuseIdentifer, for: indexPath)
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
        /// Begin footer animation
        if elementKind == UICollectionElementKindSectionFooter {
            footerView.beginAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            
            /// End footer animation
            footerView.stopAnimating()
        }
    }
}

extension SearchViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let quarterWidth = view.bounds.width * 0.4
        let halfHeight = view.bounds.height / 2
        let maxWidth = min(quarterWidth, halfHeight)
        return CGSize(width: maxWidth, height: halfHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: itemCollectionView.bounds.width, height: 50)
    }
}

extension SearchViewController : WalmartForSaleItemStoreDataDelegate {
    func saleItemsDidUpdateNewValues(forSaleItems: [WalmartForSaleItem]) {
        
        // MARK: Question : So I right now when I set items, I reload the entire tableview. How do I only reload the new data in pagination? There is so much flickering in my app.
        items = forSaleItems
        viewState = .populated
    }
    
    func saleItemsFailedUpdate() {
        items.removeAll()
        viewState = .noResults
    }
    
    
}












