//
//  GameScene.swift
//  Milestone_16-18
//
//  Created by Blaine Dannheisser on 2/11/21.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene {

    let flyingObjects = ["fly", "mosquito", "plane"]

    var gameTimer: Timer!
    var timeTimer: Timer?

    var reloadLabel: SKLabelNode!
    var shotSound: SKAction!
    var emptyClipSound: SKAction!
    var reloadSound: SKAction!

    var timerLabel: SKLabelNode!
    var timer = 60 {
        didSet {
            timerLabel.text = "Timer: \(timer)"
        }
    }

    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    var roundsLabel: SKLabelNode!
    var rounds = 6 {
        didSet {
            roundsLabel.text = "Rounds: \(rounds)"
        }
    }

    var gameOverLabel: SKLabelNode!

    // MARK: Internal

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        timerLabel = SKLabelNode(fontNamed: "Academy Engraved LET")
        timerLabel.text = "Timer: 60"
        timerLabel.position = CGPoint(x: 8, y: 80)
        timerLabel.fontSize = 46
        timerLabel.horizontalAlignmentMode = .left
        addChild(timerLabel)

        scoreLabel = SKLabelNode(fontNamed: "Academy Engraved LET")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 46
        scoreLabel.position = CGPoint(x: 8, y: 20)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)

        roundsLabel = SKLabelNode(fontNamed: "Academy Engraved LET")
        roundsLabel.text = "Rounds: 6"
        roundsLabel.fontSize = 46
        roundsLabel.position = CGPoint(x: 1000, y: 80)
        roundsLabel.horizontalAlignmentMode = .right
        addChild(roundsLabel)

        reloadLabel = SKLabelNode(fontNamed: "Academy Engraved LET")
        reloadLabel.text = "RELOAD"
        reloadLabel.fontSize = 56
        reloadLabel.fontColor = .red
        reloadLabel.alpha = 0
        reloadLabel.position = CGPoint(x: 1000, y: 20)
        reloadLabel.horizontalAlignmentMode = .right
        reloadLabel.name = "reload"
        addChild(reloadLabel)

        gameOverLabel = SKLabelNode(fontNamed: "Academy Engraved LET")
        gameOverLabel.text = "GAME OVER!"
        gameOverLabel.fontSize = 72
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.horizontalAlignmentMode = .center

        shotSound = SKAction.playSoundFileNamed("gunshot.wav", waitForCompletion: false)
        emptyClipSound = SKAction.playSoundFileNamed("emptyClip.wav", waitForCompletion: false)
        reloadSound = SKAction.playSoundFileNamed("reload.wav", waitForCompletion: false)

        physicsWorld.gravity = .zero

        startGame()
    }

//    override func update (_ currentTime: TimeInterval) {
//        for node in children {
//            if node.position.x < 1200 || node.position.x > frame.size.width + 200 {
//                node.removeFromParent()
//            }
//        }
//    }

    func startGame() {
        score = 0
        rounds = 6
        timer = 60
        timeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdownTimer), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(launchFlyingObjects), userInfo: nil, repeats: true)
        gameOverLabel.removeFromParent()
    }

    func gameOver() {
        timeTimer?.invalidate()
        gameTimer?.invalidate()
        addChild(gameOverLabel)

        scoreLabel.removeFromParent()
        timerLabel.removeFromParent()
    }

    @objc func countdownTimer() {
        timer -= 1
        if timer <= 0 {
            gameOver()
        }
    }

    @objc func launchFlyingObjects() {

        let frameSize = Int(frame.size.width)
        let height = Int.random(in: 300 ... 700)
        let direction = Int.random(in: frameSize ... frameSize + 200)

        guard let randomFlyingObject = flyingObjects.randomElement() else { return }
        let flyingObject = SKSpriteNode(imageNamed: randomFlyingObject)

        flyingObject.physicsBody = SKPhysicsBody()

        if direction.isMultiple(of: 5) {
            flyingObject.position = CGPoint(x: direction, y: height)
            flyingObject.physicsBody?.velocity = CGVector(dx: direction * -1 - 50, dy: 0)
        } else {
            flyingObject.position = CGPoint(x: direction * -1, y: height)
            flyingObject.physicsBody?.velocity = CGVector(dx: direction - 200, dy: 0)
            flyingObject.xScale = -1
        }
        if randomFlyingObject == "plane" {
            flyingObject.name = "good"
        } else {
            flyingObject.name = "bad"
        }
        addChild(flyingObject)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        guard let tappedNodes = self.nodes(at: location).first else { return }

        if rounds > 0 {
            run(shotSound)
        }

        if rounds <= 1, tappedNodes.name != "reload" {
            run(emptyClipSound)
            rounds = 0
            reloadLabel.alpha = 1
            return
        }
        rounds -= 1

        if tappedNodes.name == "bad" {
            score += 10
            run(shotSound)
            killNode(node: tappedNodes)
            bugsplat(location: tappedNodes.position)
        } else if tappedNodes.name == "good" {
            score -= 5
            run(shotSound)
            killNode(node: tappedNodes)
            explosion(location: tappedNodes.position)
        } else if tappedNodes.name == "reload" {
            rounds = 6
            run(reloadSound)
            reloadLabel.alpha = 0
        }
    }

    func killNode(node: SKNode) {
        node.removeFromParent()
    }

    func bugsplat(location: CGPoint) {
        guard let bugsplatEmitter = SKEmitterNode(fileNamed: "bugsplat") else { return }
        bugsplatEmitter.position = location
        addChild(bugsplatEmitter)
    }

    func explosion(location: CGPoint) {
        guard let explosionEmitter = SKEmitterNode(fileNamed: "explosion") else { return }
        explosionEmitter.position = location
        addChild(explosionEmitter)
    }
}
