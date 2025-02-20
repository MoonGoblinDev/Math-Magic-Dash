// Sources/Player.swift
import SpriteKit

class Player: SKSpriteNode {
    private(set) var health = 3  // Now represents the *number* of hearts.
    var playerWidth = 80
    var playerHeight = 100
    var isImmune = false // Add this property

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
        if isImmune { return } // Add this check

        health -= amount
        if health < 0 { health = 0 }

        //Removed visual
    }

    func slashAnimation(enemy: Enemy) {
        removeAction(forKey: "runningAnimation")

        // Set immunity at the start
        isImmune = true // Add this line

        var slashTextures: [SKTexture] = []
        //Assuming you named your slashing images to player-slash-1, player-slash-2, etc...
        for i in 1...4 { // How many frame do you have
            slashTextures.append(SKTexture(imageNamed: "player-slash-\(i)"))
        }

        let slashAnimation = SKAction.animate(with: slashTextures, timePerFrame: 0.05)

        // NEW: Add a slight delay before calling takeHit, so it syncs visually with the animation.
        let delayAction = SKAction.wait(forDuration: 0) // Adjust delay as needed
        let hitAction = SKAction.run { [weak self] in // Use weak self
            guard let strongSelf = self else { return }
            enemy.takeHit(from: strongSelf.position)  // <--- Call takeHit on the enemy
        }

        //Play running animation again after finish
        let runAgain = SKAction.run { [weak self] in
            guard let self = self else {return}
            self.startRunningAnimation()

            // Remove immunity at the end
            self.isImmune = false // Add this line
        }
        run(SKAction.sequence([slashAnimation, delayAction, hitAction, runAgain]), withKey: "slashAnimation") // Add withKey, delay, and run
    }
}
