// Sources/Fireball.swift
import SpriteKit

class Fireball: SKSpriteNode {
    static func spawn(at position: CGPoint, target: CGPoint) -> Fireball {
        let fireballTexture = SKTexture(imageNamed: "fireball-1") //  Start with first frame
        let fireball = Fireball(texture: fireballTexture)
        fireball.size = CGSize(width: 80, height: 80) // Adjust size as needed
        fireball.position = position
        fireball.physicsBody = SKPhysicsBody(circleOfRadius: 80)
        fireball.physicsBody?.categoryBitMask = PhysicsCategory.fireball
        fireball.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        fireball.physicsBody?.collisionBitMask = PhysicsCategory.none
        fireball.physicsBody?.affectedByGravity = false
        fireball.physicsBody?.isDynamic = false
        fireball.name = "fireball"

        fireball.animateFlight() // Start the flight animation
        fireball.shoot(towards: target)
        return fireball
    }

    func shoot(towards target: CGPoint) {
        let dx = target.x - position.x
        let dy = target.y - position.y
        let distance = sqrt(dx * dx + dy * dy)
        let normalizedDirection = CGPoint(x: dx/distance, y: dy/distance)
        let speed: CGFloat = 600
        let actionMove = SKAction.moveBy(x: normalizedDirection.x * (distance + 100), y: normalizedDirection.y * (distance + 100), duration: distance/speed)
        let actionRemove = SKAction.removeFromParent()
         run(SKAction.sequence([actionMove, actionRemove]))
    }

    private func animateFlight() {
        var flightTextures: [SKTexture] = []
        for i in 1...4 { // Assuming you have fireball-1.png, fireball-2.png, etc.
            flightTextures.append(SKTexture(imageNamed: "fireball-\(i)"))
        }
        let flightAnimation = SKAction.animate(with: flightTextures, timePerFrame: 0.05)
        run(SKAction.repeatForever(flightAnimation), withKey: "flightAnimation") // Key for removal
    }

    func explode() {  // New function for destruction
            // Stop any movement/animation.
            removeAllActions()

            // Play death animation. Assuming you have assets named "fireball-explode-1", "fireball-explode-2", etc.
            var explodeTextures: [SKTexture] = []
            for i in 1...4 { // Replace 4 with the number of death animation frames
                explodeTextures.append(SKTexture(imageNamed: "fireball-explode-\(i)"))
            }
            let explodeAnimation = SKAction.animate(with: explodeTextures, timePerFrame: 0.05)

            let removeAction = SKAction.removeFromParent()
            run(SKAction.sequence([explodeAnimation, removeAction]))
     }
}
