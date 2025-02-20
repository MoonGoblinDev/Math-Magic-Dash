// Sources/GameView.swift (Modified)
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
                        // Simply set isGameStarted to false.
                        isGameStarted = false
                        isGameOver = false // Reset isGameOver as well
                    }
                }
            } else {
                StartMenuView(isGameStarted: $isGameStarted)
            }
        }
    }
    //Remove restart function
}
