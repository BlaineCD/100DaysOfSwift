//
//  GameScene.swift
//  Project17_SpaceRace
//
//  Created by Blaine Dannheisser on 2/9/21.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    let possibleEnemies = ["chicken", "cow", "pig", "goat", "Hay"]
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var finalScore: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var newGameLabel: SKLabelNode!

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    var enemyCount = 0
    var isGameOver = false
    var gameTimer: Timer?
    var timeInterval = 1.0

    // MARK: Internal

    override func didMove(to view: SKView) {
        backgroundColor = .black

        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1

        player = SKSpriteNode(imageNamed: "tractor")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)

        scoreLabel = SKLabelNode(fontNamed: "Trebuchet MS")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)

        score = 0

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        startTimer()
    }

    func startTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }

    @objc func createEnemy() {
        guard !isGameOver else {
            gameTimer?.invalidate()
            return
        }

        if enemyCount >= 20 {
            enemyCount = 0
            timeInterval *= 0.9
            startTimer()
        }

        enemyCount += 1

        guard let enemy = possibleEnemies.randomElement() else { return }

        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50 ... 736))
        addChild(sprite)

        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)

        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        player.position = location
        }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endGame()
        }

    func didBegin(_ contact: SKPhysicsContact) {
        endGame()
    }

    func endGame() {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)

        finalScore = SKLabelNode(fontNamed: "Trebuchet MS")
        finalScore.fontSize = 76
        finalScore.position = CGPoint(x: 512, y: 384)
        finalScore.horizontalAlignmentMode = .center
        finalScore.text = "Final Score: \(score)"
        addChild(finalScore)

        newGameLabel = SKLabelNode(fontNamed: "Trebuchet MS")
        newGameLabel.position = CGPoint(x: 512, y: 340)
        newGameLabel.horizontalAlignmentMode = .center
        newGameLabel.text = "New Game"
        newGameLabel.fontColor = .yellow
        addChild(newGameLabel)

        scoreLabel.removeFromParent()
        player.removeFromParent()
        isGameOver = true
    }

    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        if !isGameOver {
            score += 1
        }
    }
}
