//
//  ViewController.swift
//  Project28_SecretSwift
//
//  Created by Blaine Dannheisser on 3/12/21.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var secret: UITextView!


    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Nothing to see here..."

        KeychainWrapper.standard.set("passw0rd", forKey: "userPassword")

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        // Called when app is backgrounded or switched to multi-tasking mode.
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }

    // MARK: Internal

    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret Stuff!"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(lockApp))

        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
    }

    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }

        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here..."
    }

    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        // is device capable of supporting biometric authentication?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify Yourself!"
            // if so, request the biometry system begin check, giving string containing reason why asking. Trailing closure -> result of policy evaluation.
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, _ in

                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        let ac = UIAlertController(title: "Authentication Failed", message: "You could not be verified, please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry Unavailable.", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.passwordAlert()

            })
            self.present(ac, animated: true)
        }
    }

    func passwordAlert() {
        let ac = UIAlertController(title: "Password", message: "Enter Your Password", preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.isSecureTextEntry = true
            textfield.placeholder = "Password"
        }

        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if ac.textFields![0].text == KeychainWrapper.standard.string(forKey: "userPassword") {
                self?.unlockSecretMessage()
            } else {
                let failAlert = UIAlertController(title: "Wrong Password", message: "Please try again", preferredStyle: .alert)
                failAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(failAlert, animated: true)
            }
        })
        present(ac, animated: true)
    }

    @objc func lockApp() {
        secret.isHidden = true
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        secret.scrollIndicatorInsets = secret.contentInset

        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
}
