//
//  GameScene.swift
//  Project20_FireworksNight
//
//  Created by Blaine Dannheisser on 2/15/21.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene {

    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22

    var gameTimer: Timer?
    var fireworks = [SKNode]()

    var scoreLabel: SKLabelNode!

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    var launchesInRound = 3
    var numOfLaunchesLabel: SKLabelNode!
    var numOfLaunches = 0 {
        didSet {
            numOfLaunchesLabel.text = "Launches: \(numOfLaunches) / 3"
        }
    }

    var explosionSFX: SKAction!
    var detonateLabel: SKLabelNode!
    var finalScoreLabel: SKLabelNode!
    var newGameLabel: SKLabelNode!

    // MARK: Internal

    override func didMove(to view: SKView) {
        launchBackground()
        displayLabels()
        explosionSFX = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }

    // New Game method: reset and set

    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)

        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)

        switch Int.random(in: 0 ... 2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        default:
            firework.color = .red
        }

        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))

        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)

        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        fireworks.append(node)
        addChild(node)
    }

    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800

        switch Int.random(in: 0 ... 3) {
        case 0:
            // straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
        case 1:
            // fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
        case 2:
            // left to right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
        case 3:
            // right to left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
        default:
            break
        }
        numOfLaunches += 1
        if numOfLaunches > launchesInRound {
            endGame()
            return
        }
    }

    func endGame() {
        gameTimer?.invalidate()

        for node in fireworks {
            node.removeFromParent()
        }

        scoreLabel.removeFromParent()
        numOfLaunchesLabel.removeFromParent()
        detonateLabel.removeFromParent()

        finalScoreLabel = SKLabelNode(fontNamed: "Futura")
        finalScoreLabel.text = "Final Score: \(score)"
        finalScoreLabel.fontColor = SKColor(named: "TextColor")
        finalScoreLabel.fontSize = 72
        finalScoreLabel.horizontalAlignmentMode = .center
        finalScoreLabel.position = CGPoint(x: 512, y: 384)
        addChild(finalScoreLabel)

        newGameLabel = SKLabelNode(fontNamed: "Futura")
        newGameLabel.text = "✨START✨NEW✨GAME✨"
        newGameLabel.fontColor = SKColor(named: "TextColor")
        newGameLabel.fontSize = 44
        newGameLabel.horizontalAlignmentMode = .center
        newGameLabel.position = CGPoint(x: 512, y: 320)
        newGameLabel.name = "restart"
        addChild(newGameLabel)
    }

    func startNewGame() {
        score = 0
        numOfLaunches = 0
        finalScoreLabel.removeFromParent()
        newGameLabel.removeFromParent()
        addChild(detonateLabel)

        gameTimer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }

    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for case let node as SKLabelNode in nodesAtPoint {
            if node.name == "detonate" {
                explodeFireworks()
//                run(explosionSFX)
                return
            }

            if node.name == "restart" {
                startNewGame()
                return
            }
        }

        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }

            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }

                if firework.name == "selected", firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }

    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }

    func explode(firework: SKNode) {
        if let emitter = SKEffectNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)

            let wait = SKAction.wait(forDuration: 3)
            let remove = SKAction.run { emitter.removeFromParent() }
            let sequence = SKAction.sequence([wait, remove])
            emitter.run(sequence)
        }
        firework.removeFromParent()
    }

    func explodeFireworks() {
        var numExploded = 0

        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }

            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                run(explosionSFX)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }

        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }

    // MARK: Fileprivate

    fileprivate func launchBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
    }

    fileprivate func displayLabels() {
        scoreLabel = SKLabelNode(fontNamed: "Futura")
        scoreLabel.fontColor = SKColor(named: "TextColor")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 32
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 24)
        addChild(scoreLabel)

        numOfLaunchesLabel = SKLabelNode(fontNamed: "Futura")
        numOfLaunchesLabel.fontColor = SKColor(named: "TextColor")
        numOfLaunchesLabel.text = "Launches: 0 / 3"
        numOfLaunchesLabel.fontSize = 32
        numOfLaunchesLabel.horizontalAlignmentMode = .left
        numOfLaunchesLabel.position = CGPoint(x: 16, y: 64)
        addChild(numOfLaunchesLabel)

        detonateLabel = SKLabelNode(fontNamed: "Futura")
        detonateLabel.text = "💥"
        detonateLabel.fontSize = 125
        detonateLabel.horizontalAlignmentMode = .right
        detonateLabel.position = CGPoint(x: 1000, y: 56)
        detonateLabel.name = "detonate"
        detonateLabel.zPosition = 1
        addChild(detonateLabel)

        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: -50, y: 25)
            detonateLabel.addChild(emitter)
        }
    }

}
