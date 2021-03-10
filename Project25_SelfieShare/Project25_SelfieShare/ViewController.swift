//
//  ViewController.swift
//  Project25_SelfieShare
//
//  Created by Blaine Dannheisser on 3/2/21.
//

import MultipeerConnectivity
import UIKit

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {

    var images = [UIImage]()

    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Selfie Share"

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.questionmark"), style: .plain, target: self, action: #selector(viewParticipants))

        let messagePrompt = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeMessage))
        let photoPrompt = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [messagePrompt, flexibleSpace, photoPrompt]
        navigationController?.isToolbarHidden = false

        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }

    // MARK: Internal

    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)

        images.insert(image, at: 0)
        collectionView.reloadData()

        guard let mcSession = mcSession else { return }
        if !mcSession.connectedPeers.isEmpty {
            if let imageData = image.pngData() {
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch {
                    let ac = UIAlertController(title: "Send Error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
    }

    @objc func composeMessage() {
        let ac = UIAlertController(title: "Send A Message", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = "Enter Message"
            textField.autocapitalizationType = .sentences
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak ac, weak self] _ in
            guard let message = ac?.textFields?[0].text else { return }
            self?.deployMessage(message)
        }))

        present(ac, animated: true)
    }

    @objc func deployMessage(_ message: String) {
        guard let mcSession = mcSession else { return }
        if !mcSession.connectedPeers.isEmpty {
            let messageData = Data(message.utf8)
            do {
                try mcSession.send(messageData, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch {
                let ac = UIAlertController(title: "Send Error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        }
    }

    @objc func viewParticipants() {
        guard let mcSession = mcSession else { return }
        let participants = mcSession.connectedPeers.map(\.displayName)

        let ac = UIAlertController(title: "Connected Participants:", message: "\(participants.joined(separator: "\n"))", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Leave session", style: .default, handler: leaveSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    func startHosting(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant?.start()
    }

    func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }

    func leaveSession(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        mcSession.disconnect()
    }

    // Required for MCSession & MCBrowswerViewController Delegates

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            disconnectedFromSession()
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            print("Unknown state received: \(peerID.displayName)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let image = UIImage(data: data) {
            DispatchQueue.main.async { [weak self] in
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            }
        } else {
            let message = String(decoding: data, as: UTF8.self)
            DispatchQueue.main.async { [weak self] in
                let ac = UIAlertController(title: "Message: \(peerID.displayName)", message: message, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Reply", style: .default, handler: self?.replyToMessage))
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(ac, animated: true)
                }
            }
        }

    func disconnectedFromSession() {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "\(self?.peerID.displayName ?? "Other Participant") has disconnected", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }

    func replyToMessage(action: UIAlertAction) {
        composeMessage()
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("Disconnected: Test 1")
    }

    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }

    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        disconnectedFromSession()
        dismiss(animated: true)
    }

    // Collection View Set Up

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)

        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]

            cell.layer.borderColor = UIColor(red: 0.1725, green: 0, blue: 0.949, alpha: 1.0).cgColor
            cell.layer.borderWidth = 3
            cell.layer.cornerRadius = 70.0
            cell.layer.masksToBounds = true

        }
        return cell
    }
}
