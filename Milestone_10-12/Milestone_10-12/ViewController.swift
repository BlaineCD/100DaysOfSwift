//
//  ViewController.swift
//  Milestone_10-12
//
//  Created by Blaine Dannheisser on 1/27/21.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var dishArray = [Dish]()
    var searchedDishes = [Dish]()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "D🍴SHES"

        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewDish))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "🔎", style: .plain, target: self, action: #selector(searchDishes)),
            UIBarButtonItem(title: "🔄", style: .plain, target: self, action: #selector(resetView))
        ]

        let defaults = UserDefaults.standard
        if let savedDishes = defaults.object(forKey: "dish") as? Data {
            let jsonDecoder = JSONDecoder()

            do {
                dishArray = try jsonDecoder.decode([Dish].self, from: savedDishes)
            } catch {
                print("Failed to load.")
            }
        }
    }

    // MARK: Internal

    @objc func addNewDish() {
        let picker = UIImagePickerController()

        if UIImagePickerController.isSourceTypeAvailable(.camera) {

            let ac = UIAlertController(title: "Allow D🍴SHES to access my photos?", message: nil, preferredStyle: .actionSheet)

            ac.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                picker.sourceType = .camera
                self?.accessPhotos(with: picker)
            })

            ac.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
                self?.accessPhotos(with: picker)
            })

            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)

        } else {
            accessPhotos(with: picker)
        }
    }

    func accessPhotos(with picker: UIImagePickerController) {
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }

        dismiss(animated: true)

        let ac = UIAlertController(title: "What's the dish?", message: "Enter Rating", preferredStyle: .alert)
        ac.addTextField()
        ac.addTextField()

        ac.textFields![0].placeholder = "Dish Name"
        ac.textFields![1].placeholder = "Rating: 1 - 10?"

        let addButton = UIAlertAction(title: "Save", style: .default) { [weak ac, weak self] _ in
            let name = ac?.textFields?[0].text
            let rating = ac?.textFields?[1].text
            self?.addDish(path: imagePath.path, name: name!, rating: rating!)
        }
        ac.addAction(addButton)

        ac.addAction(UIAlertAction(title: "Cancel", style: .default))

        present(ac, animated: true)
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func addDish(path imagePath: String, name: String, rating: String) {
        let dish = Dish(name: name, rating: rating, image: imagePath)
        dishArray.append(dish)
        searchedDishes = dishArray
        save()
        tableView.reloadData()
    }

    @objc func searchDishes() {
        let ac = UIAlertController(title: "Search D🍴SHES", message: "What dish are you searching for?", preferredStyle: .alert)
        ac.addTextField()

        let searchAction = UIAlertAction(title: "Find It", style: .default) { [weak self, weak ac] _ in
            guard let searchTerms = ac?.textFields?[0].text else { return }
            self?.returnSearchResults(searchTerms)
        }

        ac.addAction(searchAction)
        present(ac, animated: true)
    }

    func returnSearchResults(_ searchTerms: String) {
        searchedDishes.removeAll(keepingCapacity: true)
        for term in dishArray {
            if term.name.contains(searchTerms){
                searchedDishes.append(term)
                tableView.reloadData()
            }
        }
    }

    @objc func resetView() {
        searchedDishes = dishArray
        tableView.reloadData()
    }

    // MARK: Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedDishes.count
//        return dishArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Dish", for: indexPath)
//        let dish = dishArray[indexPath.row]
//        for search function:
        let dish = searchedDishes[indexPath.row]
        cell.textLabel?.text = dish.name
        cell.detailTextLabel?.text = "Rating: \(dish.rating)"
        cell.imageView?.image = UIImage(named: dish.image)

        cell.imageView?.layer.borderColor = UIColor(red: 0.1725, green: 0, blue: 0.949, alpha: 1.0).cgColor
        cell.imageView?.layer.borderWidth = 2
        cell.imageView?.layer.cornerRadius = 45.0
        cell.imageView?.layer.masksToBounds = true
        cell.layer.cornerRadius = 7

        save()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.selectedDish = dishArray[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            searchedDishes.remove(at: indexPath.row)
            dishArray.remove(at: indexPath.row)
        }
        tableView.reloadData()
        save()
    }

    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(dishArray) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "dish")
        } else {
            print("Failed to save!")
        }
    }
}
