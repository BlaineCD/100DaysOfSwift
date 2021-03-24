//
//  GameViewController.swift
//  Project29_ExplodingMonkeys
//
//  Created by Blaine Dannheisser on 3/15/21.
//

import GameplayKit
import SpriteKit
import UIKit

class GameViewController: UIViewController {
    var currentGame: GameScene!

    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var velocitySlider: UISlider!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var launchButton: UIButton!
    @IBOutlet weak var playerNumber: UILabel!

    override var shouldAutorotate: Bool {
        true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill

                // Present the scene
                view.presentScene(scene)

                currentGame = scene as? GameScene
                currentGame.viewController = self

                angleSlider.value = 45
                velocitySlider.value = 125

                angleChanged(angleSlider!)
                velocityChanged(velocitySlider!)

            }

            view.ignoresSiblingOrder = true

            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    @IBAction func angleChanged(_ sender: Any) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    @IBAction func velocityChanged(_ sender: Any) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }

    
    @IBAction func launch(_ sender: Any) {
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
        launchButton.isHidden = true

        currentGame.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
    }

    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }

        angleSlider.isHidden = false
        angleLabel.isHidden = false
        velocitySlider.isHidden = false
        velocityLabel.isHidden = false
        launchButton.isHidden = false
    }

    func endGame(winner: String) {
        let ac = UIAlertController(title: "\(winner.uppercased()) WINS!", message: "Play Again?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Play Again", style: .default) { (UIAlertAction) in
            self.currentGame?.playNewGame()
            self.currentGame?.resetScore()
        })
        ac.addAction(UIAlertAction(title: "No Thanks", style: .destructive))
        present(ac, animated: true)
    }

}
