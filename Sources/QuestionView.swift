// NEW FILE: Sources/QuestionView.swift
import SwiftUI

struct QuestionView: View {
    let problem: MathProblem
    let onAnswerSelected: (Int) -> Void  // Closure to handle answer selection

    var body: some View {
        VStack {
            Text(problem.question)
                .foregroundColor(.white)
                .font(.title)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.3)) // Background for question
                .cornerRadius(10)

            HStack {
                ForEach(0..<problem.options.count, id: \.self) { index in
                    Button(action: {
                        onAnswerSelected(index)
                    }) {
                        Text("\(problem.options[index])")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity) // Ensure equal width
                            .background(Color.blue.opacity(0.7)) // Background for options
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding() // Add padding to the whole VStack
    }
}
