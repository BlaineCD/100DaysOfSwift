//
//  GameScene.swift
//  Project11
//
//  Created by Blaine Dannheisser on 1/22/21.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var balls = ["ballRed", "ballCyan", "ballYellow", "ballGrey", "ballPurple", "ballGreen", "ballBlue"]

    var newGameLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!

    var score = 0 {
        didSet {
            updateScoreAndBalls()
        }
    }

    var ballsRemaining = 5 {
        didSet {
            updateScoreAndBalls()
        }
    }

    var editLabel: SKLabelNode!

    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }

    // MARK: Internal

    override func didMove(to view: SKView) {

        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self

        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)

        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.numberOfLines = 2
        scoreLabel.text = "Score: 0\n Balls: 5"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 650)
        addChild(scoreLabel)

        newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel.text = "New Game"
        newGameLabel.position = CGPoint(x: 120, y: 695)
        addChild(newGameLabel)

        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 650)
        addChild(editLabel)

        newGame()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)

        if objects.contains(newGameLabel) {
            newGame()
        } else if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                let size = CGSize(width: Int.random(in: 16 ... 128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0 ... 1), green: CGFloat.random(in: 0 ... 1), blue: CGFloat.random(in: 0 ... 1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0 ... 3)
                box.position = location
                box.name = "box"
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                addChild(box)
            } else {
                guard let randomBall = balls.randomElement() else { return }
                let ball = SKSpriteNode(imageNamed: randomBall)
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                ball.physicsBody?.restitution = 0.4
//                    ball.position = location
                ball.position.x = location.x
                ball.position.y = 768
                ball.name = "ball"
                if ballsRemaining <= 0 {
                    if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
                        fireParticles.position = location
                        addChild(fireParticles)
                    }
                    return
                }
                ballsRemaining -= 1
                addChild(ball)
            }
        }
    }

    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }

    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode

        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotBase.position = position
        slotGlow.position = position

        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false

        addChild(slotBase)
        addChild(slotGlow)

        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }

    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            ballsRemaining += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
//            ballsRemaining -= 1
        }
    }

    func updateScoreAndBalls() {
        scoreLabel.text = "Score: \(score)\nBalls: \(ballsRemaining)"
    }

    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }

    func newGame() {
        ballsRemaining = 5
        score = 0

        for node in self.children {
            if node.name == "box" || node.name == "ball" {
                node.removeFromParent()
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
}
