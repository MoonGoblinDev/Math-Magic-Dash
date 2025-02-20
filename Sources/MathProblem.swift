// Sources/MathProblem.swift
struct MathProblem {
    let question: String
    let options: [Int]
    let correctAnswer: Int
    let difficultyLevel: Int // Add difficulty level

    static func random(forScore score: Int) -> MathProblem {
        let operations: [String]
        let difficultyLevel: Int

        // Determine difficulty and operations based on score
        if score < 60 {
            operations = ["+", "-"]
            difficultyLevel = 1
        } else if score < 100 {
            operations = ["+", "-", "×", "÷"]
            difficultyLevel = 2
        } else if score < 200 {
            operations = ["+", "-"]
            difficultyLevel = 3
        } else {
            operations = ["+", "-", "×", "÷"]
            difficultyLevel = 4
        }

        let operation = operations.randomElement()!

        var num1: Int
        var num2: Int
        var answer: Int

        switch (operation, difficultyLevel) {
        case ("+", 1): // Single-digit addition
            num1 = Int.random(in: 1...9)
            num2 = Int.random(in: 1...9)
            answer = num1 + num2
        case ("-", 1): // Single-digit subtraction
            num1 = Int.random(in: 1...9)
            num2 = Int.random(in: 1...num1)
            answer = num1 - num2
        case ("×", 2): // Single-digit multiplication
            num1 = Int.random(in: 1...9)
            num2 = Int.random(in: 1...9)
            answer = num1 * num2
        case ("÷", 2): // Single-digit division (ensure no remainders)
            num2 = Int.random(in: 1...9)
            answer = Int.random(in: 1...9)
            num1 = num2 * answer
        case ("+", 3): // Double-digit addition
            num1 = Int.random(in: 1...10)
            num2 = Int.random(in: 10...99)
            answer = num1 + num2
        case ("-", 3): // Double-digit subtraction
            num1 = Int.random(in: 10...99)
            num2 = Int.random(in: 1...9)
            answer = num1 - num2
        case ("×", 4): // Double-digit multiplication
            num1 = Int.random(in: 10...20) //Smaller range for manage
            num2 = Int.random(in: 2...9)
            answer = num1 * num2
        case ("÷", 4): // Double-digit division (ensure no remainders)
            num2 = Int.random(in: 2...9)
            answer = Int.random(in: 10...20)
            num1 = num2 * answer
        default:
            return random(forScore: 0) // Fallback to easiest level
        }

        let question = "\(num1) \(operation) \(num2) = ?"
        var options = [answer]

        while options.count < 3 {
            let wrongAnswer: Int
              if difficultyLevel == 4 || difficultyLevel == 3 {
                wrongAnswer = answer + Int.random(in: -10...10)
              }else{
                wrongAnswer = answer + Int.random(in: -5...5)
              }
            if wrongAnswer != answer && !options.contains(wrongAnswer) {
                options.append(wrongAnswer)
            }
        }

        return MathProblem(
            question: question,
            options: options.shuffled(),
            correctAnswer: answer,
            difficultyLevel: difficultyLevel // Set the difficulty level
        )
    }
}
