// Sources/GameScene.swift
import SpriteKit
import SwiftUI

class GameScene: SKScene, @preconcurrency SKPhysicsContactDelegate {
    private var player: Player!
    private var gameUI: GameUI! // Health and Score
    private var currentProblem: MathProblem?
    private var score = 0 { //for score in swiftui purpose
         didSet {
             updateScoreView()
         }
     }
    weak var gameDelegate: GameSceneDelegate?
    private var background: ScrollingBackground!
    private var lastUpdateTime: TimeInterval = 0
    private var ground: SKSpriteNode!

    // Add a container for our SwiftUI view
    private var questionViewHostingController: UIHostingController<AnyView>?
    // Add a hosting controller for the ScoreView
    private var scoreViewHostingController: UIHostingController<ScoreView>?

    private let nearDistanceThreshold: CGFloat = 150.0
    private let farDistanceThreshold: CGFloat = 600.0 // Just to define

    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupGame()
        startGameLoop()
    }

    private func setupPhysicsWorld() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self

        ground = SKSpriteNode(color: .black, size: CGSize(width: frame.width, height: 600))
        ground.position = CGPoint(x: frame.midX, y: frame.midY - 400)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        addChild(ground)

        player = Player.createPlayer()
        player.position = CGPoint(x: frame.width * 0.2, y: ground.position.y + ground.size.height / 2 + player.size.height / 2)
        addChild(player)

        gameUI = GameUI(in: self)
        gameUI.addToScene(self)
        // Create hearts UI
        gameUI.createHearts(in: self)
        setupScoreView()

    }

    private func setupGame() {
        let backgroundTexture = SKTexture(imageNamed: "Background")
        background = ScrollingBackground(texture: backgroundTexture, gameWidth: frame.width, movementMultiplier: 0.3, yPosition: frame.midY, backgroundHeight: frame.height)
        addChild(background)
        // Don't generate a problem initially.  Wait for the enemy.
    }
   private func startGameLoop() {
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    // Generate and show problem *with* the enemy.
                    self.generateNewProblem()
                    if let problem = self.currentProblem {
                        self.spawnEnemy(problem: problem)
                    }
                },
                SKAction.wait(forDuration: 5.0)
            ])
        ))
    }

    private func spawnEnemy(problem: MathProblem) {
        let enemy = Enemy.spawn(at: CGPoint(x: frame.width + 50,
                                            y: ground.position.y + ground.size.height/2 + 40), problem: problem)
        addChild(enemy)
        enemy.startMoving()
    }

    private func generateNewProblem() {
        currentProblem = MathProblem.random()
        if let problem = currentProblem {
            // Update SwiftUI View
            updateQuestionView(with: problem)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // No longer handle answer touches here.  SwiftUI handles it.
    }

    private func handleAnswer(index: Int, correct: Bool) {
        guard let problem = currentProblem else { return }

        if correct {
            score += 10

            // Find the enemy associated with the current problem.
            var currentEnemy: Enemy?
            enumerateChildNodes(withName: "enemy") { [weak self] node, _ in
                guard let self = self else { return }
                if let enemy = node as? Enemy, enemy.associatedProblem?.question == problem.question {
                    currentEnemy = enemy
                }
            }
            guard let enemy = currentEnemy else {
                hideQuestionView()
                currentProblem = nil // VERY IMPORTANT
                return
            }

            // Calculate the distance between the player and the enemy.
            let distance = player.position.distance(to: enemy.position)

            if distance <= nearDistanceThreshold {
                // Slash attack
                player.slashAnimation(enemy: enemy) // <--- Pass the enemy to the slashAnimation
                //enemy.removeFromParent() // Remove enemy immediately on slash, no need this anymore
            } else {
                // Fireball attack, only if distance is within far range to preven fireball flying forever
                if(distance <= farDistanceThreshold){
                    let fireball = Fireball.spawn(at: player.position, target: enemy.position)
                    addChild(fireball)
                }else{
                    enemy.removeFromParent() // Remove enemy to prevent forever there
                }

            }
            // HIDE THE VIEW ON CORRECT ANSWER!
            hideQuestionView()
            currentProblem = nil // VERY IMPORTANT:  Make sure this is cleared.
        } else { //Incorrect
            hideQuestionView()
            currentProblem = nil // Reset
        }

    }

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.player | PhysicsCategory.enemy {
            if let enemy = (contact.bodyA.node as? Enemy) ?? (contact.bodyB.node as? Enemy) {
                player.takeDamage(1) // Player now loses 1 heart.
                gameUI.updateHealth(player.health) //Update health UI
                enemy.removeFromParent()
                //If hit, remove question
                hideQuestionView()
                currentProblem = nil

                if player.health <= 0 {
                    handleGameOver()
                }
            }
        }else if collision == PhysicsCategory.fireball | PhysicsCategory.enemy {
            if let fireball = contact.bodyA.node as? Fireball ?? contact.bodyB.node as? Fireball,
               let enemy = contact.bodyA.node as? Enemy ?? contact.bodyB.node as? Enemy {
                enemy.takeHit(from: fireball.position)
                fireball.explode() // Call the explosion animation
                //fireball.removeFromParent() No need remove it, because already handled inside explode

            }
        }
    }

    private func handleGameOver() {
        isPaused = true
        gameDelegate?.gameDidEnd(withScore: score)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            let deltaTime = currentTime - lastUpdateTime
            background.update(deltaTime: deltaTime)
        }
        lastUpdateTime = currentTime
    }

    // MARK: - SwiftUI Integration

    private func updateQuestionView(with problem: MathProblem) {
        // Create or update the SwiftUI view.

        let questionView = QuestionView(problem: problem) { [weak self] selectedIndex in
            guard let self = self, let problem = self.currentProblem else { return }
            let isCorrect = problem.options[selectedIndex] == problem.correctAnswer
            self.handleAnswer(index: selectedIndex, correct: isCorrect) // Call handleAnswer

        }

        if let hostingController = questionViewHostingController {
            // Update the existing view.
            hostingController.rootView = AnyView(questionView)
        } else {
            // Create a new hosting controller and add it to the scene.
            let hostingController = UIHostingController(rootView: AnyView(questionView))
            questionViewHostingController = hostingController

            // Use GameUIViewRepresentable to embed it in the SKView
            let uiView = hostingController.view!
            uiView.backgroundColor = .clear // Make the UIHostingController's view transparent
            uiView.translatesAutoresizingMaskIntoConstraints = false
            view?.addSubview(uiView)

            // Constraints to position the SwiftUI view (bottom of screen)
              NSLayoutConstraint.activate([
                uiView.leadingAnchor.constraint(equalTo: view!.leadingAnchor),
                uiView.trailingAnchor.constraint(equalTo: view!.trailingAnchor),
                uiView.bottomAnchor.constraint(equalTo: view!.safeAreaLayoutGuide.bottomAnchor, constant: -20), // Place it at the bottom
                uiView.heightAnchor.constraint(equalToConstant: 300) // Or any suitable height
              ])

        }
    }
    private func hideQuestionView() {
        questionViewHostingController?.rootView = AnyView(EmptyView()) // Set to EmptyView
    }

    // MARK: - Score View Integration
    private func setupScoreView() {
        let scoreView = ScoreView(score: score)
        let hostingController = UIHostingController(rootView: scoreView)
        scoreViewHostingController = hostingController

        let uiView = hostingController.view!
        uiView.backgroundColor = .clear
        uiView.translatesAutoresizingMaskIntoConstraints = false
        view?.addSubview(uiView)

        // Let the view size itself based on content
        hostingController.view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        hostingController.view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        NSLayoutConstraint.activate([
            uiView.topAnchor.constraint(equalTo: view!.safeAreaLayoutGuide.topAnchor, constant: 20),
            uiView.trailingAnchor.constraint(equalTo: view!.trailingAnchor, constant: -20),
            uiView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func updateScoreView() {
        let scoreView = ScoreView(score: score)
        scoreViewHostingController?.rootView = scoreView // Update the existing view
    }
}
// Extension for calculating distance between CGPoints
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(self.x - point.x, self.y - point.y)
    }
}
