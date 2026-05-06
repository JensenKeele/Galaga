//
//  GameScene.swift
//  Galaga
//
//  Created by Jensen Keele on 4/17/26.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var ship = SKSpriteNode()
    private var missle = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        createBackground()
        makeShip()
        makeMissle()
        missleLaunch()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch .location(in: self)
            ship.position.x = location.x
            ship.position.y = location.y
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch .location(in: self)
            ship.position.x = location.x
            let minY: CGFloat = -400
            let maxY: CGFloat = -200
            let clampedY = max(minY, min(location.y, maxY))//clamped limits where the ship can go in the scene
            ship.position.y = clampedY
        }
    }
    func createBackground() {
            let Stars = SKTexture(imageNamed: "Stars")
            for i in 0...1 {
                let StarsBackground = SKSpriteNode(texture: Stars)
                StarsBackground.zPosition = -1
                StarsBackground.position = CGPoint(x: 0, y: StarsBackground.size.height * CGFloat(i))
                addChild(StarsBackground)
                let moveDown = SKAction.moveBy(x: 0, y: -StarsBackground.size.height, duration: 20)
                let moveReset = SKAction.moveBy(x: 0, y: StarsBackground.size.height, duration: 0)
                let moveLoop = SKAction.sequence([moveDown, moveReset])
                let moveForever = SKAction.repeatForever(moveLoop)
                StarsBackground.run(moveForever)
            }
        }
    
    func makeShip() {
        ship.removeFromParent()
        ship = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 20))
        ship.position = CGPoint(x: frame.midX, y: frame.minY + 60)
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.size)
        ship.physicsBody?.isDynamic = false
        addChild(ship)
    }
    
    func makeMissle() {
        missle = SKSpriteNode(color: .red, size: CGSize(width: 7.5, height: 20))
        missle.physicsBody = SKPhysicsBody(rectangleOf: missle.size)
        missle.physicsBody?.isDynamic = false
        missle.position = CGPoint(x: ship.position.x, y: ship.position.y + ship.size.height / 3) // spawns the missle right on the ship
        let moveUp = SKAction.moveBy(x: 0, y: 1000, duration: 3)
        let remove = SKAction.removeFromParent()
        missle.run(SKAction.sequence([moveUp, remove]))
        addChild(missle)
    }
    
    func missleLaunch() {
        let shoot = SKAction.run { [weak self] in //weak self would break the loop if make missle goes away
            self?.makeMissle()
        }
        let delay = SKAction.wait(forDuration: 1) //determines fire rate
        let sequence = SKAction.sequence([shoot, delay]) // shows the order of operations shoot, delay, then repeat
        
        run (SKAction.repeatForever(sequence)) // repeats the sequence over and over again
    }
}
