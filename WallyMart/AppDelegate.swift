//
//  AppDelegate.swift
//  WallyMart
//
//  Created by Sami Taha on 8/13/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let destVC = SearchViewController()
        let navController = UINavigationController(rootViewController: destVC)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        return true
    }


}

