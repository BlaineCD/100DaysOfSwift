//
//  CountryListingCellTableViewCell.swift
//  Milestone_13-15
//
//  Created by Blaine Dannheisser on 2/6/21.
//

import UIKit

class CurrencyCell: UITableViewCell {
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var codeLabel: UILabel!

    func makeCurrencyLabel(currency: Currency) {
        self.currencyLabel.text = "Name: \(currency.name ?? "")"
        self.symbolLabel.text = "Symbol: \(currency.symbol ?? "")"
        self.codeLabel.text = "Code: \(currency.code ?? "")"
    }
}
