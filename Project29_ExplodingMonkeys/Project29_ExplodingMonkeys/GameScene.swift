//
//  GameScene.swift
//  Project29_ExplodingMonkeys
//
//  Created by Blaine Dannheisser on 3/15/21.
//

import SpriteKit
import GameplayKit

//SpriteKit bitmasks are described using UInt32. To make easier, use a raw value to refer to options using names. 
enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    weak var viewController: GameViewController!

    var playerOnesScoreLabel = SKLabelNode(fontNamed: "Futura")
    var playerOneScore = 0 {
        didSet {
            playerOnesScoreLabel.text = "Score: \(playerOneScore)"
        }
    }

    var playerTwoScoreLabel = SKLabelNode(fontNamed: "Futura")
    var playerTwoScore = 0 {
        didSet {
            playerTwoScoreLabel.text = "Score: \(playerTwoScore)"
        }
    }

    var buildings = [BuildingNode]()

    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!

    var currentPlayer = 1

    var windLabel: SKLabelNode!
    var wind: CGFloat = 0

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)

        createBuildings()
        createPlayers()

        playerOnesScoreLabel.text = "Score: \(playerOneScore)"
        playerOnesScoreLabel.fontSize = 46
        playerOnesScoreLabel.fontColor = .black
        playerOnesScoreLabel.zPosition = 1
        playerOnesScoreLabel.position = CGPoint(x: 100, y: 34)
        addChild(playerOnesScoreLabel)

        playerTwoScoreLabel.text = "Score: \(playerTwoScore)"
        playerTwoScoreLabel.fontSize = 46
        playerTwoScoreLabel.fontColor = .black
        playerTwoScoreLabel.zPosition = 1
        playerTwoScoreLabel.position = CGPoint(x: 924, y: 24)
        addChild(playerTwoScoreLabel)

        physicsWorld.contactDelegate = self

        windGenerator()
    }

    func windGenerator() {
        wind = CGFloat.random(in: -1...1)
        physicsWorld.gravity = CGVector(dx: wind, dy: physicsWorld.gravity.dy)

        let windSpeed = Int(abs(wind * 10))
        windLabel = SKLabelNode(fontNamed: "Futura")
        windLabel.fontSize = 17
        windLabel.color = .white
        windLabel.position = CGPoint(x: 512, y: 680)
        windLabel.horizontalAlignmentMode = .center
        addChild(windLabel)

        if wind < 0 {
            windLabel.text = "<< Wind Speed: \(windSpeed)"
        } else if wind > 0 {
            windLabel.text = "Wind Speed: \(windSpeed) >>"
        } else {
            windLabel.text = "No Wind"
        }
    }

    func createBuildings() {
        //go past screen edge
        var currentX: CGFloat = -15

        //height = 300...600, width = 80, 120, or 160
            while currentX < 1024 {
                let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
                //add two points between buildings
                currentX += size.width + 2

                let building = BuildingNode(color: UIColor.red, size: size)
                building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
                building.setup()
                addChild(building)
                buildings.append(building)
        }
    }

    func createPlayers() {
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.isDynamic = false

        //position player at the top of the second building in the array
        //add building height to player height and divide by two. Add to building's Y coordinate (Note, SpriteKit measures from center of node)
        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)

        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.isDynamic = false

        //position player at the top of the second to last building in the array
        let player2Building = buildings[buildings.count - 2]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
    }

    func launch(angle: Int, velocity: Int) {
        //How hard to throw the banana
        let speed = Double(velocity) / 10.0

        //Convert input angle to radians
        let radians = deg2rad(degrees: angle)

        //Remove banana if there is one already in the scene.
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }

        //Create a new banana
            banana = SKSpriteNode(imageNamed: "banana")
            banana.name = "banana"
            banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
            banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
            banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue
            banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue
            banana.physicsBody?.usesPreciseCollisionDetection = true
            addChild(banana)

        //Position banana up and to the left of the player. Apply angular velocity for spin
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20


        //Animate player 1 throwing banana
        let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
        let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
        let pause = SKAction.wait(forDuration: 0.15)
        let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
        player1.run(sequence)

        //move banana in the right direction
        let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
        banana.physicsBody?.applyImpulse(impulse)
            //Player 2 position, animate, move
        } else {
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20

            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)

            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
    }

    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * Double.pi / 180
}

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }

        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }
        if firstNode.name == "banana" && secondNode.name  == "player1" {
            destroy(player: player1)
            playerTwoScore += 1
        }
        if firstNode.name == "banana" && secondNode.name == "player2" {
            destroy(player: player2)
            playerOneScore += 1
        }
    }

    func destroy(player: SKSpriteNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }

        player.removeFromParent()
        banana.removeFromParent()

        if playerOneScore == 3 || playerTwoScore == 3 {
            if playerOneScore > playerTwoScore {
                viewController.endGame(winner: "Player 1")
            } else {
                viewController.endGame(winner: "Player 2")
            }
        } else {
            playNewGame()
        }

    }

    func resetScore() {
        playerOneScore = 0
        playerTwoScore = 0
    }

    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        viewController.activatePlayer(number: currentPlayer)
    }

    func playNewGame() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController.currentGame = newGame

            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            newGame.playerOneScore = self.playerOneScore
            newGame.playerTwoScore = self.playerTwoScore

            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }

    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        let buildingLocation = convert(contactPoint, to: building)
        building.hit(at: buildingLocation)

        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)

            // Eliminates 2nd collision. If a banana hits two buildings at the same time it would explode 2x and changePlayer() 2x
            banana.name = ""
            banana.removeFromParent()
            banana = nil

            changePlayer()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }

        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
//End Of File
}
