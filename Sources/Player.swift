import SpriteKit

class Player: SKSpriteNode {
    private(set) var health = 100
    
    static func createPlayer() -> Player {
        let player = Player(color: .red, size: CGSize(width: 50, height: 50))
        player.setupPhysics()
        //player.startRunningAnimation()
        return player
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        physicsBody?.collisionBitMask = PhysicsCategory.ground
    }
    
    private func startRunningAnimation() {
        let moveRight = SKAction.moveBy(x: 10, y: 0, duration: 0.1)
        let moveLeft = SKAction.moveBy(x: -10, y: 0, duration: 0.1)
        let runningSequence = SKAction.sequence([moveRight, moveLeft])
        run(SKAction.repeatForever(runningSequence))
    }
    
    func takeDamage(_ amount: Int) {
        health -= amount
        if health < 0 { health = 0 }
        
        // Visual feedback
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.2)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        run(SKAction.sequence([fadeOut, fadeIn]))
    }
}
