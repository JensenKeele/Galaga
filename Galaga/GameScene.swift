//
//  GameScene.swift
//  Galaga
//
//  Created by Jensen Keele on 4/17/26.
//

import SpriteKit
import GameplayKit
import UIKit //makes alerts work

class GameScene: SKScene {
    
    private var lives = 3
    private var ship = SKSpriteNode()
    private var missle = SKSpriteNode()
    private var enemy = SKSpriteNode()
    private var livesLabel = SKLabelNode()
    private var playingGame = false
    private var enemies: [SKSpriteNode] = []
    private var playerBullets: [SKSpriteNode] = []
   
    
    override func didMove(to view: SKView) {
        createBackground()
        restartGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        shipMovement(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        shipMovement(touches, with: event)
    }
    
    func shipMovement(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard ship.parent != nil else { return }
        for touch in touches {
            let location = touch.location(in: self)
            ship.position.x = location.x
            let minY: CGFloat = -400
            let maxY: CGFloat = -200
            let clampedY = max(minY, min(location.y, maxY))
            ship.position.y = clampedY
        }
    }
    
    func restartGame() {
       removeAllActions()
            lives = 3
            playingGame = true
            enemies.removeAll()
            playerBullets.removeAll()
            removeAllChildren()
            createBackground()
            makeLabels()
            makeShip()
            makeEnemies()
            missleLaunch()
            makeEnemyMissile()
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
        ship = SKSpriteNode(imageNamed: "Ship 1")
        ship.size = CGSize(width: 80, height: 80)
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
        let moveUp = SKAction.moveBy(x: 0, y: 1000, duration: 3) //speed of bullets
        let remove = SKAction.removeFromParent() //removes the bullet from the canvas after the duration
        missle.run(SKAction.sequence([moveUp, remove]))
        playerBullets.append(missle)
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
    
    func makeLabels() {
        livesLabel.fontSize = 18
        livesLabel.fontColor = .white
        livesLabel.fontName = "Arial"
        livesLabel.position = CGPoint(x: frame.minX + 80, y: frame.minY + 40)
        livesLabel.text = "Lives: \(lives)"
        addChild(livesLabel)
        lives = 3
        livesLabel.text = "Lives: \(lives)"
    }
    
    func loseLife() {
        lives -= 1
        livesLabel.text = "Lives: \(lives)"
        if lives <= 0 { //checks to see if the lives are up so the game can end
            gameOver()
        } else {
            respawnPlayer()
        }
    }
    
    func gameOver() {
        playingGame = false
        self.isPaused = true //pauses game actions
        let alert = UIAlertController(title: "Game Over!", message: "Would you like to play again?", preferredStyle: .alert) //controller controls what goes on the screen and not
        let restart = UIAlertAction(title: "reset", style: .default) { _ in
            
            self.isPaused = false
            
            self.removeAllActions()
            self.removeAllChildren()
            
            self.restartGame()
        }
               alert.addAction(restart)
        DispatchQueue.main.async {
               if let viewController = self.view?.window?.rootViewController {
                       viewController.present(alert, animated: true)
            }
        }
    }
    
    func makeEnemy() {
        enemy.removeFromParent()
        enemy = SKSpriteNode(imageNamed: "Enemy")
        enemy.size = CGSize(width: 30, height: 20)
        // this will help position enemy above
        enemy.position = CGPoint(x: frame.midX, y: frame.maxY + enemy.size.height / 2)
        addChild(enemy)
        // this will allow the enemy to move just above the player ship
        let moveDown = SKAction.moveTo(y: frame.midY + 120, duration: 4)
        enemy.run(moveDown)
    }
    
    func makeEnemies() {
        enemies.removeAll()
        let count = 6
        let spacing: CGFloat = 50
        for row in 0..<4 {
            for i in 0..<count {
                let enemy = SKSpriteNode(imageNamed: "Enemy")
                enemy.size = CGSize(width: 40, height: 40)
                enemy.userData = ["lives": 2]
                enemies.append(enemy)
                enemy.position = CGPoint(x: frame.midX - CGFloat(count - 1) * spacing / 2 + CGFloat(i) * spacing, y: frame.maxY + CGFloat(row) * 40)
                addChild(enemy)
                let targetY = frame.midY + 120 + CGFloat(row) * 40
                enemy.run(SKAction.moveTo(y: targetY, duration: 4))
                
            }
        }
    }
    
    func makeEnemyMissile() {
        let shoot = SKAction.run { [weak self] in
            guard let self = self, let shooter = self.enemies.randomElement() else { return }
            
            let missile = SKSpriteNode(color: .yellow, size: CGSize(width: 5, height: 10))
            missile.position = shooter.position
            self.addChild(missile)
            
            let moveDown = SKAction.moveTo(y: -500, duration: 3)
            let remove = SKAction.removeFromParent()
            
            missile.run(SKAction.sequence([moveDown, remove]))
        }
        
        let delay = SKAction.wait(forDuration: 1.5)
        let sequence = SKAction.sequence([shoot, delay])
        
        run(SKAction.repeatForever(sequence))
    }
    
    func enemyLoseLive(_ enemy: SKSpriteNode) {
        // when player hits enemy 2 times the enemy dies
        let lives = enemy.userData?["lives"] as? Int ?? 2
        let newLives = lives - 1

        if newLives <= 0 {
            enemy.removeFromParent()
            enemies.removeAll { $0 == enemy }
        } else {
            enemy.userData?["lives"] = newLives
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // helps the bullets collisons with the enemy
        for bullet in playerBullets {
            for enemy in enemies {
                if bullet.frame.intersects(enemy.frame) {
                    enemyLoseLive(enemy)
                    bullet.removeFromParent()
                    playerBullets.removeAll { $0 == bullet }
                    break
                }
            }
        }

        enemies.removeAll { $0.parent == nil }
        playerBullets.removeAll { $0.parent == nil }
        for node in children {
            if let bullet = node as? SKSpriteNode,
               bullet.color == .yellow {
                if bullet.frame.intersects(ship.frame) {
                    bullet.removeFromParent()
                    loseLife()
                }
            }
        }
    }
   
    func respawnPlayer() {
        // has ship respawn
        ship.removeFromParent()
        ship = SKSpriteNode(imageNamed: "Ship 1")
        ship.size = CGSize(width: 80, height: 80)
        ship.position = CGPoint(x: frame.midX, y: frame.minY + 60)
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.size)
        ship.physicsBody?.isDynamic = false
        addChild(ship)
    }
}
