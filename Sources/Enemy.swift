import SpriteKit

class Enemy: SKSpriteNode {
    static func spawn(at position: CGPoint) -> Enemy {
        let enemy = Enemy(color: .purple, size: CGSize(width: 40, height: 80))
        enemy.position = position
        enemy.setupPhysics()
        return enemy
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.affectedByGravity = false
    }
    
    func startMoving() {
        let moveLeft = SKAction.moveBy(x: -UIScreen.main.bounds.width - 100, y: 0, duration: 4.0)
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([moveLeft, remove]))
    }
}
