//
//  WalmartSaleItem.swift
//  WallyMart
//
//  Created by Sami Taha on 8/13/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation
/*
 In a production application we would create a customm failable intializer. For time sake, I have made all properties optional
*/
struct WalmartForSaleItem: Codable {
    let itemId: Int?
    let name: String?
    let salePrice: Double?
    let shortDescription: String?
    let largeImage: String?
    let productUrl : String?
}

extension WalmartForSaleItem : CustomStringConvertible {
    var description: String {
          return "Item ID: \(String(describing: itemId)) \n"
    }
}
