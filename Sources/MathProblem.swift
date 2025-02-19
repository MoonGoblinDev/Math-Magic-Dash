struct MathProblem {
    let question: String
    let options: [Int]
    let correctAnswer: Int
    
    static func random() -> MathProblem {
        let operations = ["+", "-", "×", "÷"]
        let operation = operations.randomElement()!
        
        var num1: Int
        var num2: Int
        var answer: Int
        
        switch operation {
        case "+":
            num1 = Int.random(in: 1...20)
            num2 = Int.random(in: 1...20)
            answer = num1 + num2
        case "-":
            num1 = Int.random(in: 1...20)
            num2 = Int.random(in: 1...num1)
            answer = num1 - num2
        case "×":
            num1 = Int.random(in: 1...12)
            num2 = Int.random(in: 1...12)
            answer = num1 * num2
        case "÷":
            num2 = Int.random(in: 1...12)
            answer = Int.random(in: 1...12)
            num1 = num2 * answer
        default:
            return random()
        }
        
        let question = "\(num1) \(operation) \(num2) = ?"
        var options = [answer]
        
        while options.count < 3 {
            let wrongAnswer = answer + Int.random(in: -5...5)
            if wrongAnswer != answer && !options.contains(wrongAnswer) {
                options.append(wrongAnswer)
            }
        }
        
        return MathProblem(
            question: question,
            options: options.shuffled(),
            correctAnswer: answer
        )
    }
}
