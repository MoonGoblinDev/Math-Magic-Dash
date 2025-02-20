// Sources/GameUI.swift (Modified)
import SpriteKit

@MainActor
class GameUI {
    private var hearts: [SKSpriteNode] = [] // Array of heart sprites.
    //private var scoreLabel: SKLabelNode //REMOVED
    private let maxHealth = 3 // Maximum number of hearts

    init(in scene: SKScene) {
        //Removed score label init
    }

    func addToScene(_ scene: SKScene) {
        //Removed healthbar
        //Removed scorelabel
    }

    func updateHealth(_ health: Int) {
        // Show/hide hearts based on the current health.
        for (index, heart) in hearts.enumerated() {
            heart.isHidden = index >= health
        }
    }
    //update score removed

    func createHearts(in scene: SKScene) {
        for i in 0..<maxHealth {
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.size = CGSize(width: 40, height: 40)
            heart.position = CGPoint(x: scene.frame.minX + 50 + CGFloat(i) * 50, y: scene.frame.height * 0.9)

            // Add these lines to color the heart red:
            heart.color = .red
            heart.colorBlendFactor = 1.0  // This is important!

            hearts.append(heart)
            scene.addChild(heart)
        }
    }

}
