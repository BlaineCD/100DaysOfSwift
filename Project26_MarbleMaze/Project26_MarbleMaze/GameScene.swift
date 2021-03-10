//
//  GameScene.swift
//  Project26_MarbleMaze
//
//  Created by Blaine Dannheisser on 3/4/21.
//

import CoreMotion
import SpriteKit

// MARK: - CollisionTypes

// SpriteKit expects these bitmasks to be described w/ UInt32
enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case portal = 16
    case finish = 32
}

// MARK: - GameScene

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!

    var level = 1

    var lastTouchPosition: CGPoint?

    var motionManager: CMMotionManager!

    var isGameOver = false

    var scoreLabel: SKLabelNode!

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    // MARK: Internal

    override func didMove(to view: SKView) {

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        // Start collection accelerometer information
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()

        playGame()
    }

    func playGame() {
        removeAllChildren()

        createBackground()
        createScoreLabel()

        level = 1
        loadLevel()
        createPlayer()
        isGameOver = false
    }

    func loadLevelFile() -> String {
        // find the url for level 1 in our bundle
        guard let levelURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") else {
            fatalError("Could not find level\(level).txt in the app bundle.")
        }
        // load the string / contents from the txt file
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle.")
        }
        return levelString
    }

    func loadLevel() {
        // loop over lines in reverse and inside there loop over every row letter by letter to get columns.
        let lines = loadLevelFile().components(separatedBy: "\n")
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)

                createNodes(letter, position)
            }
        }
    }

    func createPlayer(at position: CGPoint = CGPoint(x: 96, y: 672)) {
        player = SKSpriteNode(imageNamed: "player")
        player.position = position
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5

        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
    }

    // Method to simulate accelerometer on simulator
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location

        for node in nodes(at: location) {
            if node.name == "restart" {
                playGame()
            }
        }
    }

    // Method to simulate accelerometer on simulator
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }

    // Method to simulate accelerometer on simulator
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }

    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }

        #if targetEnvironment(simulator)
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                // device is rotate right, so flip coordinates
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
            }
        #else
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
            }
        #endif
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }

    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1

            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])

            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "entryPortal" {
            guard let teleport = self.childNode(withName: "exitPortal") else { return }
            player.removeFromParent()
            createPlayer(at: teleport.position)

        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            if level < 3 {
                nextLevel()
            } else {
                endOfGame()
            }
        }
    }

    func nextLevel() {
        isGameOver = true

        for levelNodes in children {
            if !(levelNodes.name == "background" || levelNodes.name == "scoreLabel") {
                levelNodes.removeFromParent()
            }
        }
        level += 1
        loadLevel()
        createPlayer()
        isGameOver = false
    }

    func endOfGame() {
        isGameOver = true
        removeAllChildren()
        endScreen()
    }

    func endScreen() {
        let finalScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        finalScoreLabel.text = "FINAL SCORE: \(score)"
        finalScoreLabel.fontSize = 36
        finalScoreLabel.position = CGPoint(x: 512, y: 384)
        finalScoreLabel.horizontalAlignmentMode = .center
        finalScoreLabel.zPosition = 1
        addChild(finalScoreLabel)

        let newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel.text = "PLAY AGAIN"
        newGameLabel.fontSize = 40
        newGameLabel.position = CGPoint(x: 512, y: 316)
        newGameLabel.horizontalAlignmentMode = .center
        newGameLabel.zPosition = 1
        newGameLabel.name = "restart"
        addChild(newGameLabel)
    }

    // MARK: Fileprivate

    fileprivate func createBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        background.name = "background"
        addChild(background)
    }

    fileprivate func createScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        scoreLabel.name = "scoreLabel"
        addChild(scoreLabel)
    }

    fileprivate func createNodes(_ letter: String.Element, _ position: CGPoint) {
        if letter == "x" {
            let node = SKSpriteNode(imageNamed: "block")
            node.position = position

            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
            node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
            node.physicsBody?.isDynamic = false
            addChild(node)
        } else if letter == "v" {
            let node = SKSpriteNode(imageNamed: "vortex")
            node.name = "vortex"
            node.position = position
            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
            node.physicsBody?.isDynamic = false

            node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
            node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
            node.physicsBody?.collisionBitMask = 0
            addChild(node)
        } else if letter == "s" {
            let node = SKSpriteNode(imageNamed: "star")
            node.name = "star"
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
            node.physicsBody?.isDynamic = false

            node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
            node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
            node.physicsBody?.collisionBitMask = 0
            node.position = position
            addChild(node)
        } else if letter == "f" {
            let node = SKSpriteNode(imageNamed: "finish")
            node.name = "finish"
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
            node.physicsBody?.isDynamic = false

            node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
            node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
            node.physicsBody?.collisionBitMask = 0
            node.position = position
            addChild(node)
        } else if letter == "p" {
            let node = SKSpriteNode(imageNamed: "portal")
            node.name = "entryPortal"
            node.position = position
            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
            node.physicsBody?.isDynamic = false

            node.physicsBody?.categoryBitMask = CollisionTypes.portal.rawValue
            node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
            node.physicsBody?.collisionBitMask = 0
            addChild(node)
        } else if letter == "e" {
            let node = SKSpriteNode(imageNamed: "portalExit")
            node.name = "exitPortal"
            node.position = position
            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
            node.physicsBody?.isDynamic = false

            node.physicsBody?.categoryBitMask = CollisionTypes.portal.rawValue
            node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
            node.physicsBody?.collisionBitMask = 0
            addChild(node)
        } else if letter == " " {
            // this is an empyt space, do nothing
            return
        } else {
            fatalError("Unknown level letter: \(letter)")
        }
    }
}
