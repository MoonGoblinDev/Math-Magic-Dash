// Sources/Player.swift
import SpriteKit

class Player: SKSpriteNode {
    private(set) var health = 100

    static func createPlayer() -> Player {
        let playerTexture = SKTexture(imageNamed: "Player-Run-1") // Load the texture
        let player = Player(texture: playerTexture) // Use the texture
        player.setupPhysics()
        player.startRunningAnimation()  //Start is in create player so it runs  right away
        return player
    }

    private func setupPhysics() {
        // Adjust size to match *one frame* of your animation. Very important!
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))  //Or use texture size: physicsBody = SKPhysicsBody(texture: texture!, size: texture!.size())
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        physicsBody?.collisionBitMask = PhysicsCategory.ground
    }

    func startRunningAnimation() {
        // Example animation (assuming 4 run frames)
        var runTextures: [SKTexture] = []
        for i in 1...8 {
            runTextures.append(SKTexture(imageNamed: "player-run-\(i)")) 
        }

        let runAnimation = SKAction.animate(with: runTextures, timePerFrame: 0.05)
        run(SKAction.repeatForever(runAnimation), withKey: "runningAnimation") // Use a key
    }

    func takeDamage(_ amount: Int) {
        //Stop Animate
        //removeAction(forKey: "runningAnimation")
        health -= amount
        if health < 0 { health = 0 }

        // Visual feedback (using a colorize action instead of fade)
        let colorize = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.2)
        let uncolorize = SKAction.colorize(with: .white, colorBlendFactor: 0.0, duration: 0.2) // Back to normal
        let sequence = SKAction.sequence([colorize, uncolorize])
        //Run animate again
        run(sequence) { [weak self] in
              self?.startRunningAnimation()
          }
    }
}
