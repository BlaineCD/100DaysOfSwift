//
//  ViewController.swift
//  Shopping_List
//
//  Created by Blaine Dannheisser on 1/5/21.
//

import SwiftMessages
import UIKit

// MARK: - ViewController

class ViewController: UITableViewController {
    var shoppingList = [String]()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        showMessage()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "+ New List", style: .plain, target: self, action: #selector(startNewList))

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareList)),
            UIBarButtonItem(title: "Add Item", style: .plain, target: self, action: #selector(promptToAddItems))
        ]
//
//        startNewList()
        loadItemsIfAvailable()
    }

    // MARK: Internal

    @objc func startNewList() {
        shoppingList.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }

    // Share
    @objc func shareList() {
        let finalList = shoppingList.joined(separator: ",\n")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        let currentDate = dateFormatter.string(from: Date())
        let shareMessage = "Here is my 🛒-list for \(currentDate): \(finalList)"

        let viewController = UIActivityViewController(activityItems: [shareMessage], applicationActivities: [])
        viewController.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(viewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shoppingList.count
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    // Delete Rows from Table
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let selectedItem = shoppingList[indexPath.row]
        guard shoppingList.contains(selectedItem) else { return }

        tableView.performBatchUpdates {
            shoppingList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
        } completion: { _ in
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
        cell.textLabel?.text = shoppingList[indexPath.row]
        return cell
    }

    @objc func promptToAddItems() {
        let alertController = UIAlertController(title: "Add To Your 🛒-List", message: nil, preferredStyle: .alert)
        alertController.addTextField()

        let submitItem = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] _ in

            guard let listedItem = alertController?.textFields?[0].text else {
                return
            }
            self?.submit(listedItem)
        }
        alertController.addAction(submitItem)
        present(alertController, animated: true)
    }

    func submit(_ listedItem: String) {
        shoppingList.insert(listedItem, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)

        saveItems()
    }

    // MARK: Fileprivate

    fileprivate func loadItemsIfAvailable() {
        title = "🛒-List"

        // isEditing = true

        // Bar Button Items

        let saved = fetchSavedItems()

        print("---------------- \(saved.debugDescription)")

        if let items = fetchSavedItems() as? [String] {
            print("---------------- \(items)")
            shoppingList = items
        }
    }

    fileprivate func fetchSavedItems() -> Any? {
        UserDefaults.standard.object(forKey: "shoppingList")
    }

    fileprivate func saveItems() {
        UserDefaults.standard.setValue(shoppingList, forKey: "shoppingList")
    }
}

// MARK: -

private extension ViewController {
    func showMessage() {
        // Instantiate a message view from the provided card view layout. SwiftMessages searches for nib
        // files in the main bundle first, so you can easily copy them into your project and make changes.
        let view = MessageView.viewFromNib(layout: .cardView)

        // Theme message elements with the warning style.
        view.configureTheme(.warning)

        // Add a drop shadow.
        view.configureDropShadow()

        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        let iconText = ["🥬", "🥐", "🍎", "🥦"].randomElement()!
//        view.configureContent(title: "Howdie!", body: "Consider yourself warned.", iconText: iconText)
        view.configureContent(title: "Let's Get Some Groceries!", body: nil,
                              iconImage: nil,
                              iconText: iconText,
                              buttonImage: nil,
                              buttonTitle: "Start") { _ in
        }
        // Increase the external margin around the card. In general, the effect of this setting
        // depends on how the given layout is constrained to the layout margins.
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        // Reduce the corner radius (applicable to layouts featuring rounded corners).
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10

        // Show the message.
        SwiftMessages.show(view: view)
    }
}
