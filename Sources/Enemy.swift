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
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemyWidth - 50, height: enemyHeight - 50))
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

    // New functions for hit and death
    func takeHit(from point: CGPoint) {
        // Stop any current movement
        removeAllActions()

        // Knockback. Calculate direction *away* from the impact point.
        let knockbackDistance: CGFloat = 50.0
        let dx = position.x - point.x
        let dy = position.y - point.y
        let distance = sqrt(dx * dx + dy * dy)
        let normalizedDirection = CGPoint(x: dx/distance, y: dy/distance)
        let knockbackAction = SKAction.moveBy(x: normalizedDirection.x * knockbackDistance, y: normalizedDirection.y * knockbackDistance, duration: 0.2)

        // Red tint effect (colorization)
        let colorizeAction = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1)
        let uncolorizeAction = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1) // Return to normal
        let colorSequence = SKAction.sequence([colorizeAction, uncolorizeAction])

        // Run knockback and color change concurrently
        run(knockbackAction)
        run(colorSequence) { [weak self] in
            self?.die() // Call die() *after* the hit effects
        }

    }

    private func die() {
        // Stop any movement/animation.
        removeAllActions()

        // Play death animation. Assuming you have assets named "Boar-Dead-1", "Boar-Dead-2", etc.
        var deathTextures: [SKTexture] = []
        for i in 1...4 { // Replace 4 with the number of death animation frames
            deathTextures.append(SKTexture(imageNamed: "Boar-Dead-\(i)"))
        }
        let deathAnimation = SKAction.animate(with: deathTextures, timePerFrame: 0.05)

        let removeAction = SKAction.removeFromParent()
        run(SKAction.sequence([deathAnimation, removeAction]))
    }
}
