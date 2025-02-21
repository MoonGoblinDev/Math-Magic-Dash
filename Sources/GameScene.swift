// Sources/GameScene.swift
import SpriteKit
import SwiftUI

class GameScene: SKScene, @preconcurrency SKPhysicsContactDelegate {
    private var player: Player!
    private var gameUI: GameUI!
    private var problemManager: ProblemManager!
    private var enemySpawner: EnemySpawner!
    private var itemSpawner: ItemSpawner! //Add this
    weak var gameDelegate: GameSceneDelegate?
    private var background: ScrollingBackground!
    private var lastUpdateTime: TimeInterval = 0
    private var ground: SKSpriteNode!

    private let nearDistanceThreshold: CGFloat = 150.0
    private let farDistanceThreshold: CGFloat = 600.0

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

    }

    private func setupGame() {
        let backgroundTexture = SKTexture(imageNamed: "Background")
        background = ScrollingBackground(texture: backgroundTexture, gameWidth: frame.width, movementMultiplier: 0.3, yPosition: frame.midY, backgroundHeight: frame.height)
        addChild(background)

        player = Player.createPlayer()
        player.position = CGPoint(x: frame.width * 0.2, y: ground.position.y + ground.size.height / 2 + player.size.height / 2)
        addChild(player)

        gameUI = GameUI(in: self)
        gameUI.addToScene(self)
        problemManager = ProblemManager(scene: self, gameUI: gameUI) // Pass gameUI to problem manager
        enemySpawner = EnemySpawner(scene: self)
        itemSpawner = ItemSpawner(scene: self) //Add itemSpawner

        gameUI.createHearts(in: self)
        gameUI.setupScoreView()
    }

    private func startGameLoop() {
         run(SKAction.repeatForever(
             SKAction.sequence([
                 SKAction.run { [weak self] in
                     guard let self = self else { return }
                     self.problemManager.generateNewProblem() // Now takes the score.
                     if let problem = self.problemManager.currentProblem {
                         self.enemySpawner.spawnEnemy(problem: problem, ground: self.ground)
                     }

                     //Add ItemSpawn
                     self.itemSpawner.spawnItem(ground: self.ground) //Add itemSpawner
                 },
                 SKAction.wait(forDuration: 5.0)
             ])
         ))
     }

    @MainActor func handleAnswer(index: Int, correct: Bool) {
        guard let problem = problemManager.currentProblem else {return}

            if correct {
                gameUI.score += 10
                var currentEnemy: Enemy?
                enumerateChildNodes(withName: "enemy") { [weak self] node, _ in
                    guard let self = self else { return }
                    if let enemy = node as? Enemy, enemy.associatedProblem?.question == problem.question {
                        currentEnemy = enemy
                    }
                }
                guard let enemy = currentEnemy else {
                    problemManager.hideQuestionView()
                    problemManager.clearProblem()
                    return
                }

                let distance = player.position.distance(to: enemy.position)

                if distance <= nearDistanceThreshold {
                    player.slashAnimation(enemy: enemy)
                } else {
                    // Fireball attack
                    if(distance <= farDistanceThreshold){
                        let fireball = Fireball.spawn(at: player.position, target: enemy.position)
                        addChild(fireball)
                    }else{
                        enemy.removeFromParent()
                    }

                }
                problemManager.hideQuestionView()
                problemManager.clearProblem()
            } else {
                problemManager.hideQuestionView()
                problemManager.clearProblem()
            }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.player | PhysicsCategory.enemy {
            if let enemy = (contact.bodyA.node as? Enemy) ?? (contact.bodyB.node as? Enemy) {
                player.takeDamage(1)
                gameUI.updateHealth(player.health)
                enemy.removeFromParent()
                problemManager.hideQuestionView()
                problemManager.clearProblem()

                if player.health <= 0 {
                    handleGameOver()
                }
            }
        } else if collision == PhysicsCategory.fireball | PhysicsCategory.enemy {
             if let fireball = contact.bodyA.node as? Fireball ?? contact.bodyB.node as? Fireball,
                let enemy = contact.bodyA.node as? Enemy ?? contact.bodyB.node as? Enemy {
                 enemy.takeHit(from: fireball.position)
                 fireball.explode()
             }
         } else if collision == PhysicsCategory.player | PhysicsCategory.healthItem {
            if let player = (contact.bodyA.node as? Player) ?? (contact.bodyB.node as? Player),
               let healthItem = contact.bodyA.node as? HealthItem ?? contact.bodyB.node as? HealthItem{
                healthItem.collected(by: player, gameUI: gameUI)
            }
         }else if collision == PhysicsCategory.player | PhysicsCategory.shieldItem {
            if let player = (contact.bodyA.node as? Player) ?? (contact.bodyB.node as? Player),
               let shieldItem = contact.bodyA.node as? ShieldItem ?? contact.bodyB.node as? ShieldItem{
                shieldItem.collected(by: player)
            }
         }
    }

    private func handleGameOver() {
        isPaused = true
        gameDelegate?.gameDidEnd(withScore: gameUI.score)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            let deltaTime = currentTime - lastUpdateTime
            background.update(deltaTime: deltaTime)
        }
        lastUpdateTime = currentTime
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(self.x - point.x, self.y - point.y)
    }
}
