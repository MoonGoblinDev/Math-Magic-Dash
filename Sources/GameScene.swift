// Sources/GameScene.swift
import SpriteKit

class GameScene: SKScene, @preconcurrency SKPhysicsContactDelegate {
    private var player: Player!
    private var gameUI: GameUI!
    private var currentProblem: MathProblem?
    private var score = 0
    weak var gameDelegate: GameSceneDelegate?
    private var background: SKSpriteNode! //background

    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupGame()
        startGameLoop()
    }

    private func setupPhysicsWorld() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self

        // Add ground
        let ground = SKSpriteNode(color: .green, size: CGSize(width: frame.width, height: 100))
        ground.position = CGPoint(x: frame.midX, y: 50)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        addChild(ground)

        // Add player  (No change needed here - Player creates itself)
        player = Player.createPlayer()
        player.position = CGPoint(x: frame.width * 0.2, y: ground.position.y + ground.size.height + player.size.height/2) //place on top of ground.
        addChild(player)

        // Setup UI (No change needed here)
        gameUI = GameUI(in: self)
        gameUI.addToScene(self)
    }

    private func setupGame() {
        // Set up the background.
        background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size  // Make it fill the screen
        background.zPosition = -1 // Ensure it's behind everything else
        addChild(background)
        generateNewProblem()
    }

    private func startGameLoop() { // No changes, just formatting
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    self.generateNewProblem()
                    if let problem = self.currentProblem {
                        self.spawnEnemy(problem: problem)
                    }
                },
                SKAction.wait(forDuration: 5.0)
            ])
        ))
    }

    private func spawnEnemy(problem: MathProblem) { // No changes, just formatting
        let enemy = Enemy.spawn(at: CGPoint(x: frame.width + 50,
                                          y: frame.height * 0.2), problem: problem)
        addChild(enemy)
        enemy.startMoving()
    }

    private func generateNewProblem() { // No change
        currentProblem = MathProblem.random()
        if let problem = currentProblem {
            gameUI.updateProblem(problem)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { // No change
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)

        for node in nodes {
            if let name = node.name,
               name.starts(with: "option"),
               let index = Int(name.dropFirst(6)),
               let problem = currentProblem
            {
                handleAnswer(index: index, correct: problem.options[index] == problem.correctAnswer)
           }
        }
    }

    private func handleAnswer(index: Int, correct: Bool) { // No change, just formatting
        guard let problem = currentProblem else { return }

        if correct {
            score += 10
            gameUI.updateScore(score)

            enumerateChildNodes(withName: "enemy") { [weak self] node, _ in
                guard let self = self else {return}
                if let enemy = node as? Enemy, enemy.associatedProblem?.question == problem.question {
                    enemy.removeFromParent()
                }
            }
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {// No change, just formatting
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.player | PhysicsCategory.enemy {
            if let enemy = (contact.bodyA.node as? Enemy) ?? (contact.bodyB.node as? Enemy) {
                player.takeDamage(20)
                gameUI.updateHealth(player.health)
                enemy.removeFromParent()

                if player.health <= 0 {
                    handleGameOver()
                }
            }
        }
    }

    private func handleGameOver() { // No change
        isPaused = true
        gameDelegate?.gameDidEnd(withScore: score)
    }
}
