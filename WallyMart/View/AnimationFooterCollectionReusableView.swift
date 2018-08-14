//
//  AnimationFooterCollectionReusableView.swift
//  WallyMart
//
//  Created by Sami Taha on 8/13/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import UIKit

class AnimationFooterCollectionReusableView: UICollectionReusableView {
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.stopAnimating()
    }
    
    func beginAnimating() {
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
    
    struct Constants {
        static let reuseIdentifer = "AnimationFooter"
        static let nibName = "AnimationFooter"
    }
}


