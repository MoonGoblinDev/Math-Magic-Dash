// Sources/GameOverView.swift (Modified)
import SwiftUI

struct GameOverView: View {
    let score: Int
    let onRestart: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Game Over!")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)

                Text("Score: \(score)")
                    .font(.title)
                    .foregroundColor(.white)

                Button(action: onRestart) {
                    Text("Return") // Changed text to "Return"
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
        }
    }
}
