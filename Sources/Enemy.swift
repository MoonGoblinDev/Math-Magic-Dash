// Sources/Enemy.swift
import SpriteKit

class Enemy: SKSpriteNode {
    var associatedProblem: MathProblem?
    var enemyWidth = 100
    var enemyHeight = 80

    static func spawn(at position: CGPoint, problem: MathProblem) -> Enemy {
        let enemyTexture = SKTexture(imageNamed: "Boar-Run-1")
        let enemy = Enemy(texture: enemyTexture) // Set the initial size
        enemy.size = CGSize(width: enemy.enemyWidth, height: enemy.enemyHeight)
        enemy.position = position
        enemy.setupPhysics()
        enemy.associatedProblem = problem
        enemy.name = "enemy"
        enemy.runAnimation()
        return enemy
    }

    private func setupPhysics() {
         // Match the physics body to the visual size.
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemyWidth, height: enemyHeight))
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.affectedByGravity = false
    }

    func startMoving() {
        let moveLeft = SKAction.moveBy(x: -UIScreen.main.bounds.width - 100, y: 0, duration: 4.0)
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([moveLeft, remove]))
    }

    func runAnimation() {
        // Example animation (assuming 2 run frames)
        var runTextures: [SKTexture] = []
        for i in 1...6 {
            runTextures.append(SKTexture(imageNamed: "Boar-Run-\(i)")) //e.g., enemy1, enemy2.png
        }

        let runAnimation = SKAction.animate(with: runTextures, timePerFrame: 0.1)
        run(SKAction.repeatForever(runAnimation))
    }
}
