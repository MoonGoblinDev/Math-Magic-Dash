// Sources/GameScene.swift
import SpriteKit

class GameScene: SKScene, @preconcurrency SKPhysicsContactDelegate {
    private var player: Player!
    private var gameUI: GameUI!
    private var currentProblem: MathProblem?
    private var score = 0
    weak var gameDelegate: GameSceneDelegate?
    private var background: ScrollingBackground!
    private var lastUpdateTime: TimeInterval = 0
    private var ground: SKSpriteNode! // Store the ground node

    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupGame()
        startGameLoop()
    }

    private func setupPhysicsWorld() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self

        // Add ground
        ground = SKSpriteNode(color: .black, size: CGSize(width: frame.width, height: 600))
        ground.position = CGPoint(x: frame.midX, y: frame.midY - 400) // Center the ground vertically
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        addChild(ground)

        player = Player.createPlayer()
        player.position = CGPoint(x: frame.width * 0.2, y: ground.position.y + ground.size.height/2 + player.size.height/2)
        addChild(player)

        gameUI = GameUI(in: self) // We'll modify GameUI next
        gameUI.addToScene(self)
    }

    private func setupGame() {
        let backgroundTexture = SKTexture(imageNamed: "Background")
        background = ScrollingBackground(texture: backgroundTexture, gameWidth: frame.width, movementMultiplier: 0.3, yPosition: frame.midY, backgroundHeight: frame.height)
        addChild(background)

        generateNewProblem()
    }
    private func startGameLoop() {
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

    private func spawnEnemy(problem: MathProblem) {
        let enemy = Enemy.spawn(at: CGPoint(x: frame.width + 50,
        // Calculate y position: ground.position.y + ground.size.height/2 + enemy HALF height
                                          y: ground.position.y + ground.size.height/2 + 40), problem: problem)
        addChild(enemy)
        enemy.startMoving()
    }

    private func generateNewProblem() {
        currentProblem = MathProblem.random()
        if let problem = currentProblem {
            gameUI.updateProblem(problem)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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

    private func handleAnswer(index: Int, correct: Bool) {
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
    func didBegin(_ contact: SKPhysicsContact) {
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
}
