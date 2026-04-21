//
//  GameScene.swift
//  Galaga
//
//  Created by Jensen Keele on 4/17/26.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        createBackground()
    }
    
    func createBackground() {
        let Stars = SKTexture( imageNamed: "Stars")
        for i in 0...1 {
            let StarsBackground = SKSpriteNode(texture: Stars)
            StarsBackground.zPosition = -1
            StarsBackground.position = CGPoint(x: 0, y: StarsBackground.size.height * CGFloat(i))
            addChild(StarsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -StarsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy(x: 0, y: StarsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence ([moveDown, moveReset])
            let moveForever = SKAction.repeatForever (moveLoop)
            StarsBackground.run(moveForever)
        }
    }
}
