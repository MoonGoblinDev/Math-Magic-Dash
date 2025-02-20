// Sources/Player.swift (Modified)
import SpriteKit

class Player: SKSpriteNode {
    private(set) var health = 3  // Now represents the *number* of hearts.
    var playerWidth = 80
    var playerHeight = 100

    static func createPlayer() -> Player {
        let playerTexture = SKTexture(imageNamed: "player-run-1")
        let player = Player(texture: playerTexture)
        player.size = CGSize(width: player.playerWidth, height: player.playerHeight)
        player.setupPhysics()
        player.startRunningAnimation()
        return player
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: playerWidth, height: playerHeight))
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        physicsBody?.collisionBitMask = PhysicsCategory.ground
    }

    func startRunningAnimation() {
        var runTextures: [SKTexture] = []
        for i in 1...8 {
            runTextures.append(SKTexture(imageNamed: "player-run-\(i)"))
        }

        let runAnimation = SKAction.animate(with: runTextures, timePerFrame: 0.05)
        run(SKAction.repeatForever(runAnimation), withKey: "runningAnimation")
    }

    func takeDamage(_ amount: Int) {
        health -= amount // Decrement hearts
        if health < 0 { health = 0 }

        //Removed visual
    }
}
