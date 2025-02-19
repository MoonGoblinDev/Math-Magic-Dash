import Foundation

protocol GameSceneDelegate: AnyObject {
    func gameDidEnd(withScore score: Int)
}
