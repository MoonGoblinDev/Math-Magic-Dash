// Sources/Enemy.swift
import SpriteKit

class Enemy: SKSpriteNode {
    var associatedProblem: MathProblem?

    static func spawn(at position: CGPoint, problem: MathProblem) -> Enemy {
        let enemyTexture = SKTexture(imageNamed: "Boar-Run-1") // Load texture
        let enemy = Enemy(texture: enemyTexture) // Initialize with texture
        enemy.position = position
        enemy.setupPhysics()
        enemy.associatedProblem = problem
        enemy.name = "enemy"
        enemy.runAnimation() //call the animation
        return enemy
    }

    private func setupPhysics() {
         // Adjust size to match a single frame!
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 80)) //or use texture size: physicsBody = SKPhysicsBody(texture: texture!, size: texture!.size())
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
        for i in 1...2 {
            runTextures.append(SKTexture(imageNamed: "Boar-Run-\(i)")) //e.g., enemy1, enemy2.png
        }

        let runAnimation = SKAction.animate(with: runTextures, timePerFrame: 0.3)
        run(SKAction.repeatForever(runAnimation))
    }
}
