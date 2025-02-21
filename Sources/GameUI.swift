// Sources/GameUI.swift (Corrected)
import SpriteKit
import SwiftUI

@MainActor class GameUI { // Apply @MainActor to the entire class
    private var hearts: [SKSpriteNode] = []
    private let maxHealth = 3
    var score = 0 {
        didSet {
            updateScoreView() // No longer needs explicit dispatch
        }
    }
    private weak var scene: SKScene?

    private var scoreViewHostingController: UIHostingController<ScoreView>?

    init(in scene: SKScene) {
        self.scene = scene
    }

    func addToScene(_ scene: SKScene) {
    }

    func updateHealth(_ health: Int) {
        for (index, heart) in hearts.enumerated() {
            heart.isHidden = index >= health
        }
    }

    func createHearts(in scene: SKScene) {
        for i in 0..<maxHealth {
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.size = CGSize(width: 40, height: 40)
            heart.position = CGPoint(x: scene.frame.minX + 50 + CGFloat(i) * 50, y: scene.frame.height * 0.9)
            heart.color = .red
            heart.colorBlendFactor = 1.0
            hearts.append(heart)
            scene.addChild(heart)
        }
    }

    func setupScoreView() {
        guard let scene = scene else { return }
        let scoreView = ScoreView(score: score)
        let hostingController = UIHostingController(rootView: scoreView)
        scoreViewHostingController = hostingController

        let uiView = hostingController.view!
        uiView.backgroundColor = .clear
        uiView.translatesAutoresizingMaskIntoConstraints = false
        scene.view?.addSubview(uiView)

        hostingController.view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        hostingController.view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        NSLayoutConstraint.activate([
            uiView.topAnchor.constraint(equalTo: scene.view!.safeAreaLayoutGuide.topAnchor, constant: 20),
            uiView.trailingAnchor.constraint(equalTo: scene.view!.trailingAnchor, constant: -20),
            uiView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

     func updateScoreView() {
        let scoreView = ScoreView(score: score)
        scoreViewHostingController?.rootView = scoreView
    }
}
