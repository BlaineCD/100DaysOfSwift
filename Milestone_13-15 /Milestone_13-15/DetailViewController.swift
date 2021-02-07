//
//  DetailViewController.swift
//  Milestone_13-15
//
//  Created by Blaine Dannheisser on 2/4/21.
//

import UIKit

// MARK: - DetailViewController

class DetailViewController: UITableViewController {
    var countryDetails: CountryElement!
    var countryInfo = [String]()

    @IBOutlet var countryFlag: UIImageView!

    enum Section: Int, CaseIterable {
        case generalInfo
        case languages
        case timezones
        case currencies

        var headerTitle: String {
            switch self {
            case .generalInfo:
                return "General Information"
            case .languages:
                return "Primary Languages"
            case .timezones:
                return "Timezones"
            case .currencies:
                return "Currencies"
            }
        }

        // MARK: Internal

        func sectionItems(countryDetails: CountryElement) -> [String] {
            switch self {
            case .generalInfo:
                return [
                    "Name: \(countryDetails.name)",
                    "Capital: \(countryDetails.capital)",
                    "Region: \(countryDetails.region)",
                    "Population: \(countryDetails.population)"
                ]
            case .timezones:
                return countryDetails.timezones
            case .currencies:
                var theCurrencies = [String]()
                countryDetails.currencies?.forEach {
                    let currDetails = "Name: \($0.name ?? "") Code: \($0.code ?? "") Symbol: \($0.symbol ?? "")"
                    theCurrencies.append(currDetails)
                }
                return theCurrencies
            case .languages:
                var theLanguages = [String]()
                countryDetails.languages?.forEach {
                    let langDetails = "Name: \($0.name ?? "") (\($0.nativeName ?? ""))"
                    theLanguages.append(langDetails)
                }
                return theLanguages
            }
        }
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // let sectionCount = Section.allCases.count

        title = countryDetails.name

        self.countryFlag.image = UIImage()

        DispatchQueue.main.async { [weak self] in
            let flagURL = "https://www.countryflags.io/\(self!.countryDetails.alpha2Code)/flat/64.png"
            guard let image = try? Data(contentsOf: URL(string: flagURL)!) else { return }
            self?.countryFlag.image = UIImage(data: image)
            let background = UIImage(named: "background")
            self?.countryFlag?.backgroundColor = UIColor(patternImage: background!)
        }
    }

    // MARK: Internal

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionValue = Section(rawValue: section) else { return 0 }
        return sectionValue.sectionItems(countryDetails: self.countryDetails).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Section.currencies.rawValue {
            return currencyCell(at: indexPath)
        } else {
            return cell(at: indexPath)
        }
    }

    func currencyCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Currency", for: indexPath)

        guard let currencyCell = cell as? CurrencyCell else {
            let sectionValue = Section(rawValue: indexPath.section)!
            cell.textLabel?.text = sectionValue.sectionItems(countryDetails: self.countryDetails)[indexPath.row]
            return cell
        }

//        guard let sectionValue = Section(rawValue: indexPath.section) else { return cell }

        currencyCell.makeCurrencyLabel(currency: countryDetails.currencies![indexPath.row])

        return currencyCell
    }

    func cell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Info", for: indexPath)

        guard let sectionValue = Section(rawValue: indexPath.section) else { return cell }

        cell.textLabel?.text = sectionValue.sectionItems(countryDetails: self.countryDetails)[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionValue = Section(rawValue: section) else { return nil }

        switch sectionValue {
        case .generalInfo:
            return Section.generalInfo.headerTitle
        case .timezones:
            return Section.timezones.headerTitle
        case .currencies:
            return Section.currencies.headerTitle
        case .languages:
            return Section.languages.headerTitle
        }
    }
}
