//
//  Person.swift
//  Project10_V2
//
//  Created by Blaine Dannheisser on 1/21/21.
//

import UIKit

class Person: NSObject, Codable {
    var name: String
    var image: String

    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
