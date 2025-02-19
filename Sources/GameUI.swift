// Sources/GameUI.swift
import SpriteKit

@MainActor
class GameUI {
    private var healthBar: SKSpriteNode
    private var scoreLabel: SKLabelNode
    private var questionLabel: SKLabelNode
    private var optionButtons: [SKLabelNode]

    init(in scene: SKScene) {
        // Initialize Health Bar (Position might need adjustment later)
        self.healthBar = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 20))
        self.healthBar.position = CGPoint(x: scene.frame.width * 0.1, y: scene.frame.height * 0.9)
        self.healthBar.anchorPoint = CGPoint(x: 0, y: 0.5)

        // Initialize Score Label (Position might need adjustment later)
        self.scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        self.scoreLabel.text = "Score: 0"
        self.scoreLabel.fontSize = 24
        self.scoreLabel.position = CGPoint(x: scene.frame.width * 0.9, y: scene.frame.height * 0.9)
        
        let bottomUIMargin: CGFloat = 50 // Or any suitable value

        // Initialize Question Label (Moved to the bottom)
        self.questionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        self.questionLabel.fontSize = 32
        self.questionLabel.position = CGPoint(x: scene.frame.midX, y: bottomUIMargin + 200) // Position above options
        self.questionLabel.horizontalAlignmentMode = .center // Make sure text is centered

        // Initialize Option Buttons (Moved to the bottom)
        self.optionButtons = (0..<3).map { i in
            let button = SKLabelNode(fontNamed: "AvenirNext-Bold")
            button.fontSize = 28
            // Position options horizontally, near the very bottom
            button.position = CGPoint(
                x: scene.frame.width * (0.25 + CGFloat(i) * 0.25),
                y: bottomUIMargin + 100 // Very bottom of the screen
            )
            
            button.horizontalAlignmentMode = .center
            button.name = "option\(i)"
            return button
        }
    }

    func addToScene(_ scene: SKScene) {
        scene.addChild(healthBar)
        scene.addChild(scoreLabel)
        scene.addChild(questionLabel)
        optionButtons.forEach { scene.addChild($0) }
    }

    func updateHealth(_ health: Int) {
        let healthPercentage = CGFloat(health) / 100.0
        healthBar.xScale = healthPercentage
        healthBar.color = healthPercentage > 0.5 ? .green : .red
    }

    func updateScore(_ score: Int) {
        scoreLabel.text = "Score: \(score)"
    }

    func updateProblem(_ problem: MathProblem) {
        questionLabel.text = problem.question
        for (index, button) in optionButtons.enumerated() {
            button.text = "\(problem.options[index])"
        }
    }

    func showGameOver(score: Int, in scene: SKScene) { //not called
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "Game Over! Score: \(score)"
        gameOverLabel.fontSize = 36
        gameOverLabel.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        scene.addChild(gameOverLabel)
    }
}
