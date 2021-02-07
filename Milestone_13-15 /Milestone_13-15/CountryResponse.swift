//
//  Country.swift
//  Milestone_13-15
//
//  Created by Blaine Dannheisser on 2/4/21.
// JSON API:
////https://restcountries.eu/#filter-response
////https://restcountries.eu/rest/v2/all

import Foundation

typealias CountryResponse = [CountryElement]

// MARK: - CountryElement

struct Currency: Codable {
    let code: String?
    let name: String?
    let symbol: String?
}

struct Language: Codable {
    let name: String?
    let nativeName: String?
}

struct CountryElement: Codable {
    let name: String
    let capital: String
    let region: String
    let population: Int
    let timezones: [String]
    let flag: String
    let alpha2Code: String
    let currencies: [Currency]?
    let languages: [Language]?

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case capital = "capital"
        case region  = "region"
        case population = "population"
        case timezones = "timezones"
        case flag = "flag"
        case alpha2Code = "alpha2Code"
        case currencies = "currencies"
        case languages = "languages"
    }
}
