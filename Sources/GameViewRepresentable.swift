import SwiftUI
import SpriteKit

struct GameViewRepresentable: UIViewRepresentable {
    @Binding var isGameOver: Bool
    @Binding var currentScore: Int
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.preferredFramesPerSecond = 60
        view.showsFPS = true
        view.showsNodeCount = true
        
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        scene.gameDelegate = context.coordinator
        view.presentScene(scene)
        
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: @preconcurrency GameSceneDelegate {
        var parent: GameViewRepresentable
        
        init(parent: GameViewRepresentable) {
            self.parent = parent
        }
        
        @MainActor func gameDidEnd(withScore score: Int) {
            parent.currentScore = score
            parent.isGameOver = true
        }
    }
}
