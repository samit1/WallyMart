//
//  WalmartSearchPayload.swift
//  WallyMart
//
//  Created by Sami Taha on 8/13/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation

struct WalmartSearchAPIPayload: Codable {
    let query : String
    let totalResults, start, numItems: Int
    
    /*
     This is a risky setup that is intended for a sample application. In a production application we would create a custom intialization processs that would decode each individual WalmartForSaleItem. The way this is built now is one invalid WalmartForSaleItem would cause the entire payload to be rejected 
     */
    let items: [WalmartForSaleItem]
}
