// Sources/GameScene.swift
import SpriteKit
import SwiftUI

class GameScene: SKScene, @preconcurrency SKPhysicsContactDelegate {
    // MARK: - Properties
    private var player: Player!
    private var gameUI: GameUI!
    private var currentProblem: MathProblem?
    private var score = 0 {
        didSet {
            updateScoreView()
            updateSpawnParameters()  //Update wave on score
        }
    }
    weak var gameDelegate: GameSceneDelegate?
    private var background: ScrollingBackground!
    private var lastUpdateTime: TimeInterval = 0
    private var ground: SKSpriteNode!
    private var questionViewHostingController: UIHostingController<AnyView>?
    private var scoreViewHostingController: UIHostingController<ScoreView>?
    private let nearDistanceThreshold: CGFloat = 150.0
    private let farDistanceThreshold: CGFloat = 600.0

    // Wave-related properties
    private var currentWave = 1
    private var enemiesPerWave = 1 // Start with 1 enemy per wave
    private var waveDelay: TimeInterval = 3.0 // Delay between waves
    private var problemQueue: [MathProblem] = [] // Queue WITHIN a wave
    private let enemySpawnDelay: TimeInterval = 0.5

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupGame()
        startWave() // Start the first wave directly
    }

    // MARK: - Setup (No Changes Here, but included for completeness)
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
        gameUI.createHearts(in: self)
        setupScoreView()
    }

    private func setupGame() {
        let backgroundTexture = SKTexture(imageNamed: "Background")
        background = ScrollingBackground(texture: backgroundTexture, gameWidth: frame.width, movementMultiplier: 0.3, yPosition: frame.midY, backgroundHeight: frame.height)
        addChild(background)
    }

    // MARK: - Wave Management
    private func startWave() {
        // 1. Generate problems for the wave
        problemQueue = []
        for _ in 0..<enemiesPerWave {
            problemQueue.append(MathProblem.random(forScore: score))
        }

        // 2. Start spawning enemies for this wave
        spawnNextEnemy()
    }

    private func spawnNextEnemy() {
        if !problemQueue.isEmpty {
            let problem = problemQueue.removeFirst()
            currentProblem = problem
            updateQuestionView(with: problem)

            let enemy = Enemy.spawn(at: CGPoint(x: frame.width + 50, y: ground.position.y + ground.size.height/2 + 40), problem: problem)
            addChild(enemy)
            enemy.startMoving()

            // Schedule the next enemy (if any) with a delay
            run(SKAction.sequence([
                SKAction.wait(forDuration: enemySpawnDelay),
                SKAction.run { [weak self] in
                    self?.spawnNextEnemy()
                }
            ]))
        } else { // No more, that's all
             // Wave is complete, all problems answered
             run(SKAction.sequence([
                  SKAction.wait(forDuration: waveDelay),
                  SKAction.run { [weak self] in
                      guard let self = self else { return }
                      self.currentWave += 1
                      self.startWave() // Start the next wave
                   }
              ]))
        }
    }

    // MARK: - Answer Handling
    private func handleAnswer(index: Int, correct: Bool) {
        guard let problem = currentProblem else { return }

        if correct {
            score += 10

            var currentEnemies: [Enemy] = []
            enumerateChildNodes(withName: "enemy") { [weak self] node, _ in
                guard let self = self else { return }
                if let enemy = node as? Enemy {
                    currentEnemies.append(enemy)
                }
            }

            guard let enemy = currentEnemies.first(where: { $0.associatedProblem?.question == problem.question }) else {
                return
            }

            let distance = player.position.distance(to: enemy.position)

            if distance <= nearDistanceThreshold {
                player.slashAnimation(enemy: enemy)
            } else {
                if distance <= farDistanceThreshold {
                    let fireball = Fireball.spawn(at: player.position, target: enemy.position)
                    addChild(fireball)
                } else {
                    enemy.removeFromParent()
                }
            }

            // Check if there are more problems in the QUEUE.
            if !problemQueue.isEmpty {
                currentProblem = problemQueue.removeFirst() // Get from the QUEUE
                updateQuestionView(with: currentProblem!)
            } else {
                 // IMPORTANT: Don't start a new wave *immediately*.
                 // Wait until all enemies are gone.  `spawnNextEnemy` handles that.
                hideQuestionView()
                currentProblem = nil // No current problem
            }

        } else {
            hideQuestionView()
            currentProblem = nil
        }
    }

    // ... (Rest of the methods: didBegin, handleGameOver, update,
    //      updateQuestionView, hideQuestionView, setupScoreView, updateScoreView) are the same

    private func generateNewProblem(){
        //No longer being used, problem generated per wave
    }
    // MARK: - Difficulty & Wave Progression
    private func updateSpawnParameters() {
        // Adjust enemiesPerWave and waveDelay based on score
          if score >= 60 && score < 100 {
             enemiesPerWave = 1
         } else if score >= 100 && score < 200 {
            enemiesPerWave = 1
         } else if score >= 200 {
           enemiesPerWave = 1
          }
    }

    // MARK: - Update
      override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            let deltaTime = currentTime - lastUpdateTime
            background.update(deltaTime: deltaTime)
        }
        lastUpdateTime = currentTime
    }

     // MARK: - Collision Handling

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.player | PhysicsCategory.enemy {
             if let enemy = (contact.bodyA.node as? Enemy) ?? (contact.bodyB.node as? Enemy) {
                player.takeDamage(1)
                gameUI.updateHealth(player.health)
                enemy.removeFromParent() // Remove the enemy
                hideQuestionView()
                currentProblem = nil // Clear the current problem (IMPORTANT)

                if player.health <= 0 {
                    handleGameOver()
                }
           }
        } else if collision == PhysicsCategory.fireball | PhysicsCategory.enemy {
            if let fireball = contact.bodyA.node as? Fireball ?? contact.bodyB.node as? Fireball,
               let enemy = contact.bodyA.node as? Enemy ?? contact.bodyB.node as? Enemy
            {
                enemy.takeHit(from: fireball.position)
                fireball.explode()
            }
        }
    }

    // MARK: - Game Over

    private func handleGameOver() {
        isPaused = true
        gameDelegate?.gameDidEnd(withScore: score)
    }

     // MARK: - SwiftUI Integration (Question)
    private func updateQuestionView(with problem: MathProblem) {
        let questionView = QuestionView(problem: problem) { [weak self] selectedIndex in
            guard let self = self, let problem = self.currentProblem else { return }
            let isCorrect = problem.options[selectedIndex] == problem.correctAnswer
            self.handleAnswer(index: selectedIndex, correct: isCorrect)
        }

        if let hostingController = questionViewHostingController {
            hostingController.rootView = AnyView(questionView)
        } else {
            let hostingController = UIHostingController(rootView: AnyView(questionView))
            questionViewHostingController = hostingController

            let uiView = hostingController.view!
            uiView.backgroundColor = .clear
            uiView.translatesAutoresizingMaskIntoConstraints = false
            view?.addSubview(uiView)

            NSLayoutConstraint.activate([
                uiView.leadingAnchor.constraint(equalTo: view!.leadingAnchor),
                uiView.trailingAnchor.constraint(equalTo: view!.trailingAnchor),
                uiView.bottomAnchor.constraint(equalTo: view!.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                uiView.heightAnchor.constraint(equalToConstant: 300)
            ])
        }
    }

    private func hideQuestionView() {
        questionViewHostingController?.rootView = AnyView(EmptyView())
    }

    // MARK: - SwiftUI Integration (Score)

    private func setupScoreView() {
        let scoreView = ScoreView(score: score)
        let hostingController = UIHostingController(rootView: scoreView)
        scoreViewHostingController = hostingController

        let uiView = hostingController.view!
        uiView.backgroundColor = .clear
        uiView.translatesAutoresizingMaskIntoConstraints = false
        view?.addSubview(uiView)

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
        scoreViewHostingController?.rootView = scoreView
    }
}

// MARK: - CGPoint Extension
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(self.x - point.x, self.y - point.y)
    }
}
