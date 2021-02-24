//
//  ViewController.swift
//  Project21_LocalNotifications
//
//  Created by Blaine Dannheisser on 2/17/21.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(setNotification))
    }

    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay")
            } else {
                print("Nay")
            }
        }
    }

    @objc func setNotification(){
        scheduleLocal(seconds: 5)
    }

    func scheduleLocal(seconds: TimeInterval) {
        registerCategories()
        let center = UNUserNotificationCenter.current()

        let quotes = [
            "Every morning we are born again. What we do today is what matters most - Buddha",
            "Every morning was a cheerful invitation to make my life of equal simplicity, and I may say innocence, with Nature herself. - Thoreau",
            "To simply wake up every morning a better person than when I went to bed. - Sidney Poitier"
        ]

        let content = UNMutableNotificationContent()
        content.title = "Wake Up"
        content.body = quotes.randomElement()!
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

//        var dateComponents = DateComponents()
//        dateComponents.hour = 10
//        dateComponents.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//        center.removeAllPendingNotificationRequests()

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let show = UNNotificationAction(identifier: "show", title: "OK, I'm awake.", options: .foreground)
        let remind = UNNotificationAction(identifier: "remind", title: "Snooze...", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remind], intentIdentifiers: [])

        center.setNotificationCategories([category])
}

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo

        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")

            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                learnMore()
                print("Default identifier")

            case "show":
                signUpNow()
                print("Show more information…")

            case "remind":
            scheduleLocal(seconds: 6)
            print("Remind me later...")

            default:
                break
            }
        }


        completionHandler()
    }

    func signUpNow() {
        let ac = UIAlertController(title: "OK, I'm awake", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    func learnMore() {
        let ac = UIAlertController(title: "Snooze", message: "6 more seconds of sleep.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

