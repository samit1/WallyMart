//
//  SearchAPI.swift
//  WallyMart
//
//  Created by Sami Taha on 8/13/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation
/*
 Changes made from last session with Ludo:
 
 1. nothing is static except the constants I am using
 2. No longer creating a new URLSession each time the search function gets called. Instead I use the shared URL session
 3. I am now implementing the shared cache (although not working,lol), thoughts?
 
 
 */

struct WalmartSearchAPI {
    
    enum SearchResults {
        case success(WalmartSearchAPIPayload)
        case failure(Error)
    }
    
    private enum Endpoint : String {
        case search = "/v1/search"
    }

    private func generateAPIURL(endPoint: Endpoint, parameters: [String: String]) -> URL? {
        
        var components = URLComponents(string: Constants.baseURL)
        components?.path = endPoint.rawValue
        
        var urlQueryItems = [URLQueryItem]()
        for (key,value) in parameters {
            let queryItem = URLQueryItem(name: key, value: value)
            urlQueryItems.append(queryItem)
        }
        
        components?.queryItems = urlQueryItems
        print(components?.url)
        return components?.url
    }
    
    enum SearchNumItems : Int {
        case ten = 10
        case fifteen = 15
        case twenty = 20
        case twentyFive = 25
    }
    
    /// Search for an item on the Walmart API via keyword. Searching is performed on background thread and calls `onCompletion` on the main thread.
    /// - parameter query: The name of item to search for
    /// - parameter onCompletion: Completion handler to call once search returns
    
    func search(query: String, numItems: SearchNumItems,resultStart: Int = 1, onCompletion: @escaping (SearchResults) -> () ) {
        
        let baseParams = [
            "query" : query,
            "format" : "json",
            "apiKey" : Constants.apiKey,
            "start" : String(resultStart),
            "numItems" : String(numItems.rawValue)
        ]
        guard let url = generateAPIURL(endPoint: .search, parameters: baseParams) else {
            // MARK: Question: Do I need to dispatch the main queue here? I have an escaping closure but I haven't called anything on the background thread
            DispatchQueue.main.async {
                onCompletion(.failure(NetworkingErrors.invalidURL))
            }
            
            return
        }
        
        
        let cache = URLCache.shared
        let request = URLRequest(url: url)
        
        DispatchQueue.global(qos: .userInitiated).async {
            // QUESTION: I can't get my results to cache here. I don't know why. I take the same approach with caching my images but here cache.cachedResponsedForRequest is returning nil
            if let data = cache.cachedResponse(for: request)?.data {
                print("search found in cache")
                /// try parsing data into model object
                // MARK: Question: self.parseSearchPayload does not cause a retain cycle because this struct is not a reference type. Can you confirm?
                guard let parsedPayload = self.parseSearchPayload(data: data) else {
                    /// if data does not parse correctly then remove from cache and notify
                    print(String(data: data, encoding: String.Encoding.utf8)!
)
                    cache.removeCachedResponse(for: request)
                    onCompletion(.failure(NetworkingErrors.jsonParsingError))
                    return
                }
                
                DispatchQueue.main.async {
                    onCompletion(.success(parsedPayload))
                    print("search request cache retrieved")
                }
            } else {
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, errror) in
                    DispatchQueue.main.async {
                        if let response = response, let data = data {
                            let cachedData = CachedURLResponse(response: response, data: data)
                            guard let parsedPayload = self.parseSearchPayload(data: data) else {
                                onCompletion(.failure(NetworkingErrors.jsonParsingError))
                                return
                            }
                            
                            cache.storeCachedResponse(cachedData, for: request)

                            onCompletion(.success(parsedPayload))
                        } else {
                            onCompletion(.failure(NetworkingErrors.invalidResponse))
                        }
                    }
                    
                }).resume()
            }
        }
    }
    
    private func parseSearchPayload(data: Data) -> WalmartSearchAPIPayload? {
        return try? JSONDecoder().decode(WalmartSearchAPIPayload.self, from: data)
    }
    
    private struct Constants {
        static let baseURL = "http://api.walmartlabs.com"
        static let apiKey = "zk8b3g2fajt6bde5mddrpfdn"
    }
    
    
}
