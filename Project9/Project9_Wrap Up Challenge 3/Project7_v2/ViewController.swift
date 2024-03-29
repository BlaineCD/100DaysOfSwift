//
//  ViewController.swift
//  Project7_v2
//
//  Created by Blaine Dannheisser on 1/9/21.
//

import UIKit

class ViewController: UITableViewController {
    //MARK: Properties
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    
    //MARK: View Mgmt
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "🔎", style: .plain, target: self, action: #selector(searchPetitions)),
            UIBarButtonItem(title: "🔄", style: .plain, target: self, action: #selector(resetView))
        ]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credit", style: .plain, target: self, action: #selector(showCredits))
        
        let urlString:String
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                filteredPetitions = petitions
                return
            }
        }
        showError()
    }
    
    //MARK: Methods
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.reloadData()
        }
    }
    
    func showError() {
        let alertController = UIAlertController(title: "Loading Error", message: "Try again...", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    @objc func showCredits() {
        let alertController = UIAlertController(title: "White House Petitions:", message: "Data feed provided courtesey of the We The People API of the White House 🏛️", preferredStyle: .alert)
        let acceptCredit = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(acceptCredit)
        present(alertController, animated: true)
    }
    
    @objc func searchPetitions() {
        let alertController = UIAlertController(title: "Search 🔎", message: "Enter your search terms:", preferredStyle: .alert)
        alertController.addTextField()
        
        let searchAction = UIAlertAction(title: "Search Now", style: .default) { [weak self, weak alertController] _ in
            guard let searchTerms = alertController?.textFields?[0].text else { return }
            self?.search(searchTerms)
        }
        alertController.addAction(searchAction)
        present(alertController, animated: true)
    }
    
    fileprivate func refreshDatasource(_ keyword: Petition) {
        filteredPetitions.append(keyword)

        DispatchQueue.main.async {
            // update the UI on the main thread.
            self.tableView.reloadData()
        }

    }

    func search(_ searchTerms: String) {
        // do work on the background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.filteredPetitions.removeAll(keepingCapacity: true)
            self?.petitions.forEach { keyword in
                if keyword.title.contains(searchTerms) {
                    self?.refreshDatasource(keyword)
                }
            }
        }
    }
    
    @objc func resetView() {
        filteredPetitions = petitions
        tableView.reloadData()
    }
    
    //MARK: Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell 
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = DetailViewController()
        viewController.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
}

