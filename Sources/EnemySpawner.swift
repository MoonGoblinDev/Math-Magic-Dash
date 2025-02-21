// Sources/EnemySpawner.swift
import SpriteKit

class EnemySpawner {
    private weak var scene: SKScene?

    init(scene: SKScene) {
        self.scene = scene
    }

    @MainActor func spawnEnemy(problem: MathProblem, ground: SKSpriteNode) { // Pass ground to spawner
        guard let scene = scene else { return }
        let enemy = Enemy.spawn(at: CGPoint(x: scene.frame.width + 50,
                                            y: ground.position.y + ground.size.height/2 + 40), problem: problem)
        scene.addChild(enemy)
        enemy.startMoving()
    }
}
