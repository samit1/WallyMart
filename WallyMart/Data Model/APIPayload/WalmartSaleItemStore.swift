//
//  WalmartSaleItemStore.swift
//  WallyMart
//
//  Created by Sami Taha on 8/14/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation

protocol WalmartForSaleItemStoreDataDelegate : class {
    func saleItemsDidUpdateNewValues(forSaleItems: [WalmartForSaleItem])
    func saleItemsFailedUpdate()
}

class WalmartForSaleItemStore {
    
    /// Items available for sale
    private var saleItems = [WalmartForSaleItem]()
    
    /// API used for searching
    private var walMartAPI = WalmartSearchAPI()
    
    /// The number of items that have been requested. Used for pagination
    private var itemsRequested = 0
    
    /// The last item that was searched. Used to check for race conditions
    private var lastSearch : String?
    
    weak var delegate : WalmartForSaleItemStoreDataDelegate?
    
    func requestNextPage() {
        guard let query = lastSearch else {
            print("there is nothing to page because lastSearch is nil")
            return
        }
        
        let numRequest = WalmartSearchAPI.SearchNumItems.ten
        itemsRequested += numRequest.rawValue
        performSearch(query: query, numRequest: numRequest, fromStart: itemsRequested)
        
    }
    
    
    func requestNewItems(query: String) {
        saleItems.removeAll()
        lastSearch = query
        let numRequest = WalmartSearchAPI.SearchNumItems.twenty
        itemsRequested = numRequest.rawValue
        performSearch(query: query, numRequest: numRequest)
    }
    
    private func performSearch(query: String, numRequest : WalmartSearchAPI.SearchNumItems, fromStart: Int = 1) {
        walMartAPI.search(query: query, numItems: numRequest, resultStart: fromStart) { [weak self] (searchResult) in
            guard self?.lastSearch == query else {
                print("Non-error notification: search \(query) is no longer needed, the requested item has changed to \(String(describing: self?.lastSearch))")
                return
            }
            switch searchResult {
            case .failure(let error):
                print(error)
                self?.delegate?.saleItemsFailedUpdate()
            case .success(let payload):
                self?.saleItems += payload.items
                if let sSelf = self {
                    sSelf.delegate?.saleItemsDidUpdateNewValues(forSaleItems: sSelf.saleItems)
                }
                
            }
        }
    }
    
}
