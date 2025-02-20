// Sources/ScoreView.swift (Modified)
import SwiftUI

struct ScoreView: View {
    let score: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.title2)
            Text("\(score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 9)
        .background(Color.black)
        .cornerRadius(10)
        .fixedSize(horizontal: true, vertical: false) // Add this
    }
}
