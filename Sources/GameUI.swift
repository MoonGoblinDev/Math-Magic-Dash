// Sources/GameUI.swift (Modified)
import SpriteKit

@MainActor
class GameUI {
    private var hearts: [SKSpriteNode] = [] // Array of heart sprites.
    private var scoreLabel: SKLabelNode
    private let maxHealth = 3 // Maximum number of hearts

    init(in scene: SKScene) {
        self.scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        self.scoreLabel.text = "Score: 0"
        self.scoreLabel.fontSize = 24
        self.scoreLabel.position = CGPoint(x: scene.frame.width * 0.9, y: scene.frame.height * 0.9)
    }

    func addToScene(_ scene: SKScene) {
      //Removed healthbar
        scene.addChild(scoreLabel)
    }

    func updateHealth(_ health: Int) {
        // Show/hide hearts based on the current health.
        for (index, heart) in hearts.enumerated() {
            heart.isHidden = index >= health
        }
    }

    func updateScore(_ score: Int) {
        scoreLabel.text = "Score: \(score)"
    }

    func createHearts(in scene: SKScene) {
        for i in 0..<maxHealth {
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.color = .red
            heart.colorBlendFactor = 1.0
            heart.size = CGSize(width: 40, height: 40) // Adjust size as needed
            heart.position = CGPoint(x: scene.frame.minX + 50 + CGFloat(i) * 50, y: scene.frame.height * 0.9) // adjust position
            hearts.append(heart)
            scene.addChild(heart)
        }
    }

}
