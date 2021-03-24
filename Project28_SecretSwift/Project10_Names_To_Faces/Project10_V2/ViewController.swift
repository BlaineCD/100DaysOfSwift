//
//  ViewController.swift
//  Project10
//
//  Created by Blaine Dannheisser on 1/19/21.
//
import LocalAuthentication
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var people = [Person]()

    var unlockButton: UIBarButtonItem!
    var lockButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        unlockButton = UIBarButtonItem(title: "🔒", style: .plain, target: self, action: #selector(authenticate))
        lockButton = UIBarButtonItem(title: "🔓", style: .plain, target: self, action: #selector(lock))
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))

        navigationItem.leftBarButtonItem = unlockButton

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(lockScreen), name: UIApplication.willResignActiveNotification, object: nil)
    }

    // MARK: Internal

    @objc func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify Yourself"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, _ in
                DispatchQueue.main.async {
                    if success {
                        self?.loadPeople()
                        self?.collectionView.reloadData()
                        self?.navigationItem.leftBarButtonItem = self?.lockButton
                        self?.navigationItem.rightBarButtonItem = self?.addButton
                    } else {
                        let ac = UIAlertController(title: "Authentication Failed", message: "You could not be verified, please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometrics Unavailable", message: "Your device is not configured for biometric authentication", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true)
        }
    }

    func loadPeople() {
        if let savedPeople = KeychainWrapper.standard.data(forKey: "people") {
            let jsonDecoder = JSONDecoder()

            do {
                people = try jsonDecoder.decode([Person].self, from: savedPeople)
                print("Load Successful")
                collectionView.reloadData()
            } catch {
                print("Failed to load")
            }
        }
    }

    @objc func lockScreen() {
       people = [Person]()
        collectionView.reloadData()
        lockButton.isEnabled = false
        unlockButton.isEnabled = true
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        people.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue Person Cell")
        }

        let person = people[indexPath.item]
        cell.name.text = person.name

        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)

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
        guard let image = info[.editedImage] as? UIImage else { return }

        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)

        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }

        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        save()

        dismiss(animated: true)
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Edit Image", message: nil, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
            self?.renamePerson(at: indexPath)
        })

        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.people.remove(at: indexPath.item)
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
            self?.collectionView.reloadData()
        })

        present(alertController, animated: true)
    }

    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(people) {
        KeychainWrapper.standard.set(savedData, forKey: "people")
        } else {
            print("Failed to save")
        }
    }

   @objc func lock() {
        save()
        people.removeAll(keepingCapacity: true)
        collectionView.reloadData()

        navigationItem.leftBarButtonItem = unlockButton
    }
}
