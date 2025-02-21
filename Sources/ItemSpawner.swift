// Sources/ItemSpawner.swift
import SpriteKit

class ItemSpawner {
    private weak var scene: SKScene?

    init(scene: SKScene) {
        self.scene = scene
    }

    @MainActor func spawnItem(ground: SKSpriteNode) { // Pass ground to spawner
        guard let scene = scene else { return }
      
        //Random select HealthItem or ShieldItem
        let random = Int.random(in: 0...1)

        //Define item based on random
        var item: SKSpriteNode
        if(random == 0){
            item = HealthItem.spawn(at: CGPoint(x: CGFloat.random(in: 0...(scene.frame.width - 50)),
                y: ground.position.y + ground.size.height/2 + 50))
        }else{
            item = ShieldItem.spawn(at: CGPoint(x: CGFloat.random(in: 0...(scene.frame.width - 50)),
                y: ground.position.y + ground.size.height/2 + 50))
        }
        
        scene.addChild(item)
    }
}
