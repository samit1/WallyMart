//
//  SaleWebViewController.swift
//  WallyMart
//
//  Created by Sami Taha on 8/14/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import UIKit

class SaleWebViewController: UIViewController {
    
    private var webView : UIWebView = {
        let webview = UIWebView()
        webview.translatesAutoresizingMaskIntoConstraints = false
        return webview
    }()
    
    var url : URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        addConstraints()
        loadWebViewIfPossible()
    }
    
    private func addSubviews() {
        view.addSubview(webView)
    }
    
    private func addConstraints() {
        let margins = view.safeAreaLayoutGuide
        webView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }
    
    private func loadWebViewIfPossible() {
        guard let url = url else {
            print("url is nil")
            return
        }
        
        let request = URLRequest(url: url)
        self.webView.loadRequest(request)
    }
}


