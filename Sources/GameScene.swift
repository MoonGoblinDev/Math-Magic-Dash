import SpriteKit

class GameScene: SKScene, @preconcurrency SKPhysicsContactDelegate {
    private var player: Player!
    private var gameUI: GameUI!
    private var currentProblem: MathProblem?
    private var score = 0
    weak var gameDelegate: GameSceneDelegate?
    
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
        
        // Add player
        player = Player.createPlayer()
        player.position = CGPoint(x: frame.width * 0.2, y: ground.position.y + ground.size.height)
        addChild(player)
        
        // Setup UI
        gameUI = GameUI(in: self)
        gameUI.addToScene(self)
    }
    
    private func setupGame() {
        backgroundColor = .systemBlue
        generateNewProblem()
    }
    
    private func startGameLoop() {
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in
                    self?.spawnEnemy()
                    self?.generateNewProblem()
                },
                SKAction.wait(forDuration: 5.0)
            ])
        ))
    }
    
    private func spawnEnemy() {
        let enemy = Enemy.spawn(at: CGPoint(x: frame.width + 50,
                                          y: frame.height * 0.2))
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
               let problem = currentProblem {
                handleAnswer(index: index, correct: problem.options[index] == problem.correctAnswer)
            }
        }
    }
    
    private func handleAnswer(index: Int, correct: Bool) {
        if correct {
            score += 10
            gameUI.updateScore(score)
            removeAllEnemies()
        }
    }
    
    private func removeAllEnemies() {
        enumerateChildNodes(withName: "enemy") { node, _ in
            node.removeFromParent()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.player | PhysicsCategory.enemy {
            // Handle player-enemy collision
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
}
