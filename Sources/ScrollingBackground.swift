// Sources/ScrollingBackground.swift (Corrected)

import SpriteKit

class ScrollingBackground: SKNode {

    private var backgrounds: [SKSpriteNode] = []
    private let movementMultiplier: CGFloat
    private let backgroundHeight: CGFloat  // Store the desired height
    private let gameWidth: CGFloat

    init(texture: SKTexture, gameWidth: CGFloat, movementMultiplier: CGFloat = 0.5, yPosition: CGFloat, backgroundHeight: CGFloat) { // Add backgroundHeight parameter
        self.movementMultiplier = movementMultiplier
        self.backgroundHeight = backgroundHeight // Use the passed-in height
        self.gameWidth = gameWidth
        super.init()

        // Calculate the aspect ratio of the texture.
        let textureAspectRatio = texture.size().width / texture.size().height

        // Calculate the width of *one* background image, based on desired height.
        let backgroundWidth = textureAspectRatio * backgroundHeight

        // Calculate the number of backgrounds needed.
        let numberOfBackgrounds = Int(ceil((gameWidth / backgroundWidth) * (1/movementMultiplier))) + 1

        for i in 0..<numberOfBackgrounds {
            let background = SKSpriteNode(texture: texture)
            // Use backgroundWidth and the provided backgroundHeight
            background.size = CGSize(width: backgroundWidth, height: backgroundHeight)
            background.anchorPoint = CGPoint(x: 0, y: 0.5)
            // Correctly position based on the calculated width
            background.position = CGPoint(x: CGFloat(i) * backgroundWidth * movementMultiplier, y: yPosition)
            background.zPosition = -1
            backgrounds.append(background)
            addChild(background)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: TimeInterval) {
        for background in backgrounds {
            background.position.x -= 200 * movementMultiplier * CGFloat(deltaTime)

            // Reposition using the calculated background width
            if background.position.x + background.size.width < 0 {
              background.position.x += background.size.width * CGFloat(backgrounds.count) * movementMultiplier
            }
        }
    }
}
