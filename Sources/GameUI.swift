import SpriteKit

@MainActor // Add MainActor attribute to the whole class
class GameUI {
    private var healthBar: SKSpriteNode
    private var scoreLabel: SKLabelNode
    private var questionLabel: SKLabelNode
    private var optionButtons: [SKLabelNode]
    
    init(in scene: SKScene) {
        // Initialize Health Bar
        self.healthBar = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 20))
        self.healthBar.position = CGPoint(x: scene.frame.width * 0.1, y: scene.frame.height * 0.9)
        self.healthBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        // Initialize Score Label
        self.scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        self.scoreLabel.text = "Score: 0"
        self.scoreLabel.fontSize = 24
        self.scoreLabel.position = CGPoint(x: scene.frame.width * 0.9, y: scene.frame.height * 0.9)
        
        // Initialize Question Label
        self.questionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        self.questionLabel.fontSize = 32
        self.questionLabel.position = CGPoint(x: scene.frame.midX, y: scene.frame.height * 0.7)
        
        // Initialize Option Buttons
        self.optionButtons = (0..<3).map { i in
            let button = SKLabelNode(fontNamed: "AvenirNext-Bold")
            button.fontSize = 28
            button.position = CGPoint(x: scene.frame.width * CGFloat(0.25 + Double(i) * 0.25),
                                    y: scene.frame.height * 0.6)
            button.name = "option\(i)"
            return button
        }
    }
    
    // Mark all methods that modify UI elements with @MainActor
    @MainActor
    func addToScene(_ scene: SKScene) {
        scene.addChild(healthBar)
        scene.addChild(scoreLabel)
        scene.addChild(questionLabel)
        optionButtons.forEach { scene.addChild($0) }
    }
    
    @MainActor
    func updateHealth(_ health: Int) {
        let healthPercentage = CGFloat(health) / 100.0
        healthBar.xScale = healthPercentage
        healthBar.color = healthPercentage > 0.5 ? .green : .red
    }
    
    @MainActor
    func updateScore(_ score: Int) {
        scoreLabel.text = "Score: \(score)"
    }
    
    @MainActor
    func updateProblem(_ problem: MathProblem) {
        questionLabel.text = problem.question
        for (index, button) in optionButtons.enumerated() {
            button.text = "\(problem.options[index])"
        }
    }
    
    @MainActor
    func showGameOver(score: Int, in scene: SKScene) {
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "Game Over! Score: \(score)"
        gameOverLabel.fontSize = 36
        gameOverLabel.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        scene.addChild(gameOverLabel)
    }
}
