//
//  ViewController.swift
//  Project2
//
//  Created by Blaine Dannheisser on 1/2/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!

    var countries = [String]()

    var score = 0
    var correctAnswer = 0
    var questionCount = 0

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]

        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1

        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor

        askQuestion(action: nil)
    }

    // MARK: Internal

    func askQuestion(action: UIAlertAction!) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0 ... 2)

        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)

        title = countries[correctAnswer].uppercased() + " | Current Score: \(score)"
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var answerMsg: String

        if sender.tag == correctAnswer {
            answerMsg = "Correct"
            score += 1
            questionCount += 1
        } else {
            answerMsg = "Wrong! That's the flag of \(countries[sender.tag].uppercased())"
            score -= 1
            questionCount += 1
        }

        if questionCount < 10 {
            let alertController = UIAlertController(title: answerMsg, message: "Your score is \(score)!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            present(alertController, animated: true)
        } else {
            let finalalertController = UIAlertController(title: answerMsg, message: "Thanks for playing! Your final score is \(score)!", preferredStyle: .alert)
            finalalertController.addAction(UIAlertAction(title: "Play Again", style: .default, handler: startNewGame))
            present(finalalertController, animated: true)
        }
    }

    func startNewGame(action: UIAlertAction) {
        score = 0
        questionCount = 0
        askQuestion(action: nil)
    }
}
