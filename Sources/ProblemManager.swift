// Sources/ProblemManager.swift (Modified)
import SpriteKit
import SwiftUI

@MainActor class ProblemManager: ObservableObject {
    @Published var currentProblem: MathProblem?
    private var questionViewHostingController: UIHostingController<AnyView>?
    private weak var scene: SKScene?
    private var gameUI: GameUI // Add to get the score

     init(scene: SKScene, gameUI: GameUI) { // Pass GameUI to get the score
         self.scene = scene
         self.gameUI = gameUI
     }

    func generateNewProblem() {
        currentProblem = MathProblem.random(forScore: gameUI.score) //Use gameUI to pass the score
        if let problem = currentProblem {
            updateQuestionView(with: problem)
        }
    }

    private func updateQuestionView(with problem: MathProblem) {
        guard let scene = scene else { return }

        let questionView = QuestionView(problem: problem) { [weak self] selectedIndex in
            guard let self = self, let problem = self.currentProblem else { return }
            let isCorrect = problem.options[selectedIndex] == problem.correctAnswer
            if let gameScene = self.scene as? GameScene {
                gameScene.handleAnswer(index: selectedIndex, correct: isCorrect)
            }
        }

        if let hostingController = questionViewHostingController {
            hostingController.rootView = AnyView(questionView)
        } else {
            let hostingController = UIHostingController(rootView: AnyView(questionView))
            questionViewHostingController = hostingController

            let uiView = hostingController.view!
            uiView.backgroundColor = .clear
            uiView.translatesAutoresizingMaskIntoConstraints = false
            scene.view?.addSubview(uiView)

            NSLayoutConstraint.activate([
              uiView.leadingAnchor.constraint(equalTo: scene.view!.leadingAnchor),
              uiView.trailingAnchor.constraint(equalTo: scene.view!.trailingAnchor),
              uiView.bottomAnchor.constraint(equalTo: scene.view!.safeAreaLayoutGuide.bottomAnchor, constant: -20),
              uiView.heightAnchor.constraint(equalToConstant: 300)
            ])
        }
    }

    func hideQuestionView() {
        questionViewHostingController?.rootView = AnyView(EmptyView())
    }

    func clearProblem(){
        currentProblem = nil
    }
}
