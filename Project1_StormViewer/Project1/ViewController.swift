//
//  ViewController.swift
//  Project1
//
//  Created by Blaine Dannheisser on 1/19/21.
//

import UIKit

class ViewController: UITableViewController {

    var pictures = [String]()

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
                pictures.sort()
            }
        }
    }

    // MARK: Internal

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pictures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            viewController.selectedImage = pictures[indexPath.row]
            viewController.title = "Picture \(indexPath.row + 1) of \(pictures.count)"
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
