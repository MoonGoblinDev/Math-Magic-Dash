// Sources/HealthItem.swift
import SpriteKit

class HealthItem: SKSpriteNode {
    static func spawn(at position: CGPoint) -> HealthItem {
        let texture = SKTexture(imageNamed: "heart") // Use the same heart image
        let item = HealthItem(texture: texture)
        item.size = CGSize(width: 30, height: 30) // Adjust size as needed
        item.position = position
        item.setupPhysics()
        item.name = "healthItem" //For debug purpose only
        return item
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.categoryBitMask = PhysicsCategory.healthItem
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.affectedByGravity = false
        physicsBody?.isDynamic = false
    }

    func collected(by player: Player, gameUI: GameUI) {
        // Increase health
        if player.health < 3 {
            player.health += 1
            gameUI.updateHealth(player.health)
            removeFromParent()
        }
    }
}
