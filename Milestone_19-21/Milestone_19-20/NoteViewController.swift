//
//  NoteViewController.swift
//  Milestone_19-20
//
//  Created by Blaine Dannheisser on 2/21/21.
//

import UIKit

class NoteViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    var note: Note!


    
    override func viewDidLoad() {
        super.viewDidLoad()

        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareNote))
        toolbarItems = [share]

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)

    }

    //keyboard adjust
    
    @objc func shareNote() {
        let vc = UIActivityViewController(activityItems: [note!], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        textView.scrollIndicatorInsets = textView.contentInset

        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }

}
