//
//  ViewController.swift
//  Milestone_25-27
//
//  Created by Blaine Dannheisser on 3/9/21.
//

import CoreGraphics
import UIKit

// MARK: - ViewController

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    var share = UIImage(systemName: "square.and.arrow.up")

    var topText = ""
    var bottomText = ""

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Meme Maker"

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: share, style: .plain, target: self, action: #selector(shareMeme))

        button.layer.cornerRadius = 25
    }

    // MARK: Internal

    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    @objc func shareMeme() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else {
            print("Sorry, no meme found.")
            return
        }
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addCaptionButton(_ sender: Any) {
        let ac = UIAlertController(title: "Add Captions", message: nil, preferredStyle: .alert)

        ac.addTextField { (textfield) in
            textfield.placeholder = "Top Caption Goes Here"
        }
        ac.addTextField { (textfield) in
            textfield.placeholder = "Bottom Caption Goes Here"
        }
        ac.addAction(UIAlertAction(title: "Done", style: .default) { [weak self, weak ac] _ in
            self?.topText = ac?.textFields![0].text ?? ""
            self?.bottomText = ac?.textFields![1].text ?? ""
            self?.imageView.image = self?.addTextToMakeMeme()
        })
        present(ac, animated: true, completion: nil)
    }

    func addTextToMakeMeme() -> UIImage {
        guard let selectedPhoto = imageView.image else { return UIImage() }

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: imageView.frame.width, height: imageView.frame.height))
        let image = renderer.image { ctx in

            let rect = CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height)
            selectedPhoto.draw(in: rect)

            let paragraphyStyle = NSMutableParagraphStyle()
            paragraphyStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36, weight: .heavy),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -0.5,
                .paragraphStyle: paragraphyStyle
            ]

            for i in 0 ... 1 {
                var memeText = ""
                var textRect = CGRect()
                if i == 0 {
                    textRect = CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height / 2)
                    memeText = topText
                } else {
                    textRect = CGRect(x: 0, y: imageView.frame.height - 50, width: imageView.frame.width, height: imageView.frame.height / 2)
                    memeText = bottomText
                }

                let text = NSAttributedString(string: memeText.uppercased(), attributes: attributes)
                UIColor.black.setStroke()
                ctx.cgContext.strokePath()
                text.draw(with: textRect, options: .usesLineFragmentOrigin, context: nil)
                imageView.contentMode = .center
            }
        }
        return image
    }

}
