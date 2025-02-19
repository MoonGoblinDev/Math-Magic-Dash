import SwiftUI
import SpriteKit

struct GameView: View {
    @State private var isGameStarted = false
    @State private var isGameOver = false
    @State private var currentScore = 0
    
    var body: some View {
        ZStack {
            if isGameStarted {
                GameViewRepresentable(
                    isGameOver: $isGameOver,
                    currentScore: $currentScore
                )
                .ignoresSafeArea()
                
                if isGameOver {
                    GameOverView(score: currentScore) {
                        restartGame()
                    }
                }
            } else {
                StartMenuView(isGameStarted: $isGameStarted)
            }
        }
    }
    
    private func restartGame() {
        isGameOver = false
        currentScore = 0
        // This will trigger a new game scene creation
        isGameStarted = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isGameStarted = true
        }
    }
}
