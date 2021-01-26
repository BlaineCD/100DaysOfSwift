//
//  ViewController.swift
//  Project10
//
//  Created by Blaine Dannheisser on 1/19/21.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var people = [Person]()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.backgroundView = imageView

        let defaults = UserDefaults.standard
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {
                people = decodedPeople
            }
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    // MARK: Internal

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "marble.jpg")
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    // Return number of items
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        people.count
    }

    // Return Person Cell or crash
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue Person Cell")
        }
        // Pull out the person from the people array at the correct position
        let person = people[indexPath.item]
        // Assign person name to the text of the label.
        cell.name.text = person.name

        // Create a UIImage from the person's image filename, adding it to the value from getDocDir() so that we have path for the image.
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)

        // Add border and rounded corners.
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 60
        cell.layer.cornerRadius = 7

        return cell
    }

    @objc func addNewPerson() {
        let picker = UIImagePickerController()

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController(title: "Access My Photos?", message: nil, preferredStyle: .actionSheet)

            alertController.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                picker.sourceType = .camera
                self?.accessPhoto(with: picker)
            })

            alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
                self?.accessPhoto(with: picker)
            })

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            present(alertController, animated: true)
        } else {
            accessPhoto(with: picker)
        }
    }

    func accessPhoto(with picker: UIImagePickerController) {
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Attempt to find the edited image and typecast it to a UIImage
        guard let image = info[.editedImage] as? UIImage else { return }

        // Generate a unique filename for every image to copy it to disk.
        let imageName = UUID().uuidString
        // Read documents directory from the application and append the file.
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)

        // Convert jpeg to Data in jpeg format and try to write to the disk.
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }

        // Create a new person instance.
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()

        dismiss(animated: true)
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    // User Tap -> Pull person object at array index tapped and show alert controller to rename.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Edit Image", message: nil, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
            self?.renamePerson(at: indexPath)
        })

        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.people.remove(at: indexPath.item)
            self?.save()
            self?.collectionView.reloadData()
        })

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alertController, animated: true)
    }

    func renamePerson(at indexPath: IndexPath) {
        let person = people[indexPath.item]
        let alertController = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
        alertController.addTextField()

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak alertController] _ in
            guard let newName = alertController?.textFields?[0].text else { return }

            person.name = newName
            self?.save()
            self?.collectionView.reloadData()

        })

        present(alertController, animated: true)
    }

    func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        }
    }
}
