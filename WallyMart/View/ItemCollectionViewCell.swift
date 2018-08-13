//
//  ItemCollectionViewCell.swift
//  WallyMart
//
//  Created by Sami Taha on 8/13/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    /// Price label
    @IBOutlet private var priceLabel: UILabel!
    
    /// Image
    @IBOutlet private var imgView: UIImageView!
    
    /// Path of image, used to check for race conditions
    private var imgPath : URL!
    
    /// Last URL request, used to cancel previous data tasks before cell reuse
    private var lastRequest : URLRequest?
    
    
    /// Configures the cell
    func configureCell(price: Double?, imgURL: String?) {
        setImg(with: imgURL)
        setPrice(price)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelPreviousTaskForCell()
        setImg(with: nil)
        setPrice(nil)
    }
    
    /// Sets the cell's image
    private func setImg(with imgURL: String?) {
        if let imgURL = imgURL, let url = URL(string: imgURL) {
            fetchImg(url: url) { [weak self] (result) in
                guard let sSelf = self else {return}
                switch result {
                case .success(let img):
                    sSelf.imgView.image = img
                case .failure:
                    print("img fetch failed")
                }
            }
        } else {
            imgView.image = nil
        }
    }
    
    
    /// Sets the cell's price label
    private func setPrice(_ price : Double?) {
        if let price = price {
            priceLabel.text = "$" + String(price)
        } else {
            priceLabel.text = ""
        }
    }
  
    /// Finds and cancels the `lastRequest`
    private func cancelPreviousTaskForCell() {
        URLSession.shared.getTasksWithCompletionHandler { [weak self] (dataTasks, _, _) in
            guard let sSelf = self else {return}
            for task in dataTasks {
                if task.currentRequest == sSelf.lastRequest {
                    task.cancel()
                }
            }
        }
    }
    
    /// Fetches an image
    private func fetchImg(url: URL, onCompletion: @escaping (PhotoFetchResult) -> ()) {
        let cache = URLCache.shared
        let request = URLRequest(url: url)
        imgPath = url
        
        if let response = cache.cachedResponse(for: request) {
            if let img = UIImage(data: response.data) {
                DispatchQueue.main.async {
                    onCompletion(.success(img))
                }
            } else {
                cache.removeCachedResponse(for: request)
            }
        } else {
            let _ = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, _) in
                guard let sSelf = self else {return}
                DispatchQueue.main.async {
                    /// Check against race condition
                    guard url == sSelf.imgPath else {
                        onCompletion(.failure)
                        return
                    }
                    guard let data = data, let response = response else {
                        print("Img data not retrieved in fetch")
                        onCompletion(.failure)
                        return
                    }
                    
                    guard let img = UIImage(data: data) else {
                        print("Img conversion failed")
                        onCompletion(.failure)
                        return
                    }
                    let cachedData = CachedURLResponse(response: response, data: data)
                    cache.storeCachedResponse(cachedData, for: request)
                    onCompletion(.success(img))
                }
            }).resume()
        }
        
        
        
    }
    
    /// Photo fetch can either be successful or a failure. A successful result will include an image.
    private enum PhotoFetchResult {
        case success(UIImage)
        case failure
    }
    
    // QUESTION:
    /// Using the nibName here - that is a normal practice for nib's right?
    struct Constants {
        static let reuseIdentifier = "WallmartItemCell"
        static let nibName = "ItemCollectionViewCell"
    }
    
}
