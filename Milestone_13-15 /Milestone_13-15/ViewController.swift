//
//  ViewController.swift
//  Milestone_13-15
//
//  Created by Blaine Dannheisser on 2/4/21.
//

import UIKit

class ViewController: UITableViewController {
    var countries = [CountryElement]()
    var searchedCountries = [CountryElement]()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Country Viewer"

        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "🔎", style: .plain, target: self, action: #selector(searchCountry)),
            UIBarButtonItem(title: "🔄", style: .plain, target: self, action: #selector(refresh))
        ]

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "More Info", style: .plain, target: self, action: #selector(moreInfo))

        let flagsOfTheWorld = UIImage(named: "flags")
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 200))
        header.backgroundColor = UIColor(patternImage: flagsOfTheWorld!)
        tableView.tableHeaderView = header

//        self.tableView.estimatedRowHeight = 80
        let countriesURL = "https://restcountries.eu/rest/v2/all"

        if let url = URL(string: countriesURL) {
            do {
                let data = try Data(contentsOf: url)
                let jsonCountries = try JSONDecoder().decode([CountryElement].self, from: data)
                countries = jsonCountries
                searchedCountries = countries
            } catch {
                print("Error")
            }
        }
    }

    // MARK: Internal

    @objc func searchCountry() {
        let ac = UIAlertController(title: "Search Countries", message: "Enter country name:", preferredStyle: .alert)
        ac.addTextField()

        let searchAction = UIAlertAction(title: "Search Now", style: .default) { [weak self, weak ac] _ in
            guard let searchTerms = ac?.textFields?[0].text else { return }
            self?.showSearch(searchTerms)
        }

        ac.addAction(searchAction)
        present(ac, animated: true)
    }

    func showSearch(_ searchTerms: String) {
        searchedCountries.removeAll(keepingCapacity: true)
        for keyword in countries {
            if keyword.name.contains(searchTerms) {
                searchedCountries.append(keyword)
                tableView.reloadData()
            }
        }
    }

    @objc func refresh() {
        searchedCountries = countries
        tableView.reloadData()
    }

    @objc func moreInfo() {
        let ac = UIAlertController(title: "Country Viewer", message: "Data Feed provided by restCountries.eu and flag images provided by countryflags.io", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    // Table View Setup:

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchedCountries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let countryLabelCell = cell as? CountryListingCellTableViewCell else {
            return cell
        }

        let country = searchedCountries[indexPath.row]

        DispatchQueue.main.async {
            let flagURL = "https://www.countryflags.io/\(country.alpha2Code)/shiny/64.png"
            guard let image = try? Data(contentsOf: URL(string: flagURL)!) else { return }
            countryLabelCell.flagImageView?.image = UIImage(data: image)
        }

//        countryLabelCell.flagImageView?.layer.borderColor = UIColor.black.cgColor
//        countryLabelCell.flagImageView?.layer.borderWidth = 1
//        countryLabelCell.flagImageView?.layer.cornerRadius = 5
        countryLabelCell.flagImageView?.layer.backgroundColor = UIColor.white.cgColor
        countryLabelCell.countryNameLabel.text = country.name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(identifier: "CountryDetail") as? DetailViewController {
            viewController.countryDetails = searchedCountries[indexPath.row]
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    //    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
}

