// Sources/ShieldItem.swift
import SpriteKit

class ShieldItem: SKSpriteNode {
    static func spawn(at position: CGPoint) -> ShieldItem {
       //Assuming you have like shield.png
        let texture = SKTexture(imageNamed: "shield")
        let item = ShieldItem(texture: texture)
        item.size = CGSize(width: 30, height: 30) // Adjust size as needed
        item.position = position
        item.setupPhysics()
        item.name = "shieldItem" //For debug purpose only
        return item
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.categoryBitMask = PhysicsCategory.shieldItem
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.affectedByGravity = false
        physicsBody?.isDynamic = false
    }

    func collected(by player: Player) {
        // Give immunity
        player.isImmune = true
        // Optional: Add a visual effect on the player to show the shield
        let fadeOut = SKAction.fadeOut(withDuration: 3.0)
        let fadeIn = SKAction.fadeIn(withDuration: 0.0)  // Make sure it's visible again

        player.run(fadeOut) {
            player.isImmune = false;
            player.run(fadeIn)
        }
        removeFromParent()
    }
}
