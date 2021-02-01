//
//  ViewController.swift
//  Project1
//
//  Created by Blaine Dannheisser on 1/19/21.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    var stormDictionary = [String: Int]()

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true

        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)

        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
                stormDictionary[item] = 0
            }
            pictures.sort()
        }

        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "stormDictionary") as? Data,
           let savedPictures = defaults.object(forKey: "pictures") as? Data
        {
            let jsonDecoder = JSONDecoder()

            do {
                stormDictionary = try jsonDecoder.decode([String: Int].self, from: savedData)
                pictures = try jsonDecoder.decode([String].self, from: savedPictures)
            } catch {
                print("Failed")
            }
        }
    }

    // MARK: Internal

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pictures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        let picture = pictures[indexPath.row]
        cell.textLabel?.text = pictures[indexPath.row]
        cell.detailTextLabel?.text = "View Count: \(stormDictionary[picture]!)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            viewController.selectedImage = pictures[indexPath.row]
            viewController.title = "Picture \(indexPath.row + 1) of \(pictures.count)"
            navigationController?.pushViewController(viewController, animated: true)
        }

        let picture = pictures[indexPath.row]
        stormDictionary[picture]! += 1
        save()
        tableView.reloadData()
    }

    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(stormDictionary),
           let savedPictures = try? jsonEncoder.encode(pictures)
        {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "stormDictionary")
            defaults.set(savedPictures, forKey: "pictures")
        } else {
            print("Failed")
        }
    }
}
