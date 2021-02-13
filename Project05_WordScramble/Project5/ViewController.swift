//
//  ViewController.swift
//  Project5
//
//  Created by Blaine Dannheisser on 12/28/20.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(startGame))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))

        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }

        startGame()
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let alertController = UIAlertController(title: "Enter word:", message: nil, preferredStyle: .alert)
        alertController.addTextField()

        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] _ in
        
            guard let answer = alertController?.textFields?[0].text else {
                return
            }
            
            self?.submit(answer)
        }

        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }
    
    fileprivate func presentResult(title: String, errorMessage: String) {
        let ac = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let submittedWord = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: submittedWord) {
            if isOriginal(word: submittedWord) {
                if isReal(word: submittedWord) {
                    if isShort (word: submittedWord) {
                        if isEqual (word: submittedWord) {
                    usedWords.insert(answer, at :0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                        } else {
                            errorTitle = "This is the same word"
                            errorMessage = "This is almost cheating!"
                        }
                    } else {
                        errorTitle = "Word too short"
                        errorMessage = "Choose a longer word"
                    }
                } else {
                    errorTitle = "Word not recognized"
                    errorMessage = "Please enter a valid word"
                }
            } else {
                errorTitle = "Word already used"
                errorMessage = "Submit a unique word"
            }
        } else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title!.lowercased())"
        }
        
        presentResult(title: errorTitle, errorMessage: errorMessage)
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
            
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isShort(word: String) -> Bool {
        if word.count < 3 {
            return false
        }
        return true
    }
    
    func isEqual(word: String) -> Bool {
        if word == title {
            return false
        }
        return true
    }
}
