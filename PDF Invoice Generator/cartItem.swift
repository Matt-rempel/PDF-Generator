//
//  cartItem.swift
//  PDF Invoice Generator
//
//  Created by Matthew Rempel on 2019-01-24.
//  Copyright © 2019 Matthew Rempel. All rights reserved.
//

import Foundation

class cartItem {
    var price: Double!
    var title: String!
    var quantity: Int!
    
    init(itemTitle:String, itemPrice:Double, itemQuantity:Int) {
        title = itemTitle
        price = itemPrice
        quantity = itemQuantity
    }
}
