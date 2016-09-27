//
//  Product.swift
//  ILoveIt
//
//  Created by Kevin Walter on 9/8/16.
//  Copyright © 2016 Kevin Walter. All rights reserved.
//

import UIKit

class Product {
    // MARK: Properties
    var id: String?
    var name: String
    var brand: String
    var category: String
    var rating: Int
    var comments: String?
    
    // MARK: Init
    
    init?(id: String?, name: String, brand: String, category: String, rating: Int, comments: String?) {
        self.id = id
        self.name = name
        self.brand = brand
        self.category = category
        self.rating = rating
        self.comments = comments
        
        if name.isEmpty || rating < 0 || rating > 5 {
            return nil
        }
    }
}