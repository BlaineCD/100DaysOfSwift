//
//  Capital.swift
//  Project16_CapitalCities
//
//  Created by Blaine Dannheisser on 2/8/21.
//

import MapKit
import UIKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var wikipediaPage: String

    init(title: String, coordinate: CLLocationCoordinate2D, info: String, wikipediaPage: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.wikipediaPage = wikipediaPage
    }
}
