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
    
    /// Name
    @IBOutlet private var nameLabel: UILabel!
    
    /// Description
    @IBOutlet private var descriptionLabel: UILabel!
    
    
    /// Path of image, used to check for race conditions
    private var imgPath : URL!
    
    /// Last URL request, used to cancel previous data tasks before cell reuse
    private var lastRequest : URLRequest?
    
    
    /// Configures the cell
    func configureCell(price: Int, imgURL: String, title: String, description: String) {
        setImg(with: imgURL)
        setPrice(String(price))
        setTitle(title)
        setDescription(description)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelPreviousTaskForCell()
        setImg(with: nil)
        setPrice("")
        setTitle("")
        setDescription("")
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
    private func setPrice(_ price : String) {
        priceLabel.text = String(price)
    }
    
    /// Sets the cell's title label
    private func setTitle(_ title : String) {
        nameLabel.text = title
    }
    
    /// Sets the cell's description label
    private func setDescription(_ description : String) {
        descriptionLabel.text = description
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
    
    /// Photo fetch can either be successful or a failure. A successful result will include an image.
    private enum PhotoFetchResult {
        case success(UIImage)
        case failure
    }
    
    struct Constants {
        static let reuseIdentifier = "WallmartItemCell"
    }
    
}
