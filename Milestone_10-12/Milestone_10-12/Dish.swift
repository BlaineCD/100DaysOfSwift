//
//  Dish.swift
//  Milestone_10-12
//
//  Created by Blaine Dannheisser on 1/27/21.
//

import UIKit

class Dish: NSObject, Codable {
    var name: String
    var rating: String
    var image: String

    init(name: String, rating: String, image: String) {
        self.name = name
        self.rating = rating
        self.image = image
    }
}
