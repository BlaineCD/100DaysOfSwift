//
//  ViewController.swift
//  Milestone_19-20
//
//  Created by Blaine Dannheisser on 2/21/21.
//

import UIKit

class ViewController: UITableViewController {

    let defaults = UserDefaults.standard

    var notes = [Note]() {
        didSet {
            save()
            noteCount = notes.count
        }
    }

    let noteCountLabel = UILabel()
    var noteCount = 0 {
        didSet {
            noteCountLabel.text = "\(noteCount) Notes"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // title
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true

        // nav buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editNoteRows))

        // set-up tool bar buttons
        let compose = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newNote))
        let counter = UIBarButtonItem(customView: noteCountLabel)
        noteCountLabel.text = "\(noteCount) Notes"
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [flexibleSpace, counter, flexibleSpace, compose]
        navigationController?.isToolbarHidden = false


    }

    @objc func newNote() {
        let ac = UIAlertController(title: "New Note", message: "What do you want to call your note?", preferredStyle: .alert)
        ac.addTextField()
        let textField = ac.textFields?[0]
        textField?.placeholder = "Note Title"


        ac.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak textField] _ in
            guard let noteTitle = textField?.text else { return }
            let newNote = Note(title: noteTitle, text: "")
            self?.notes.append(newNote)

        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }

    @objc func editNoteRows() {

    }

    // table view set-up

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].title
        cell.detailTextLabel?.text = notes[indexPath.row].text
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "NoteView") as? NoteViewController {
            vc.note = notes[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // save using codable
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(notes) {
            defaults.set(savedData, forKey: "note")
        } else {
            print("Failed to save")
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    func loadNotes() {
        if let savedNotes = defaults.object(forKey: "note") as? Data {
            let jsonDecoder = JSONDecoder()

            do {
                notes = try jsonDecoder.decode([Note].self, from: savedNotes)
            } catch {
                print("Failed to load")
            }
        }
    }
}

