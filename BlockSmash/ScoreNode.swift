//
// -----------------------------------------
// Original project: BlockSmash
// Original package: BlockSmash
// Created on: 13/12/2025 by: Steven Barnett
// Web: http://www.sabarnett.co.uk
// GitHub: https://www.github.com/sabarnett
// -----------------------------------------
// Copyright © 2025 Steven Barnett. All rights reserved.
//

import SpriteKit

class ScoreNode: SKNode {

    var scoreLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")

    init(score: HighScore, isLatest: Bool = false) {
        super.init()

        if isLatest {
            let bgNode = SKShapeNode(rect: CGRect(x: -160, y: -9, width: 320, height: 42))
            bgNode.fillColor = .green
            addChild(bgNode)
        }

        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .black
        scoreLabel.text = score.score.formatted(.number.precision(.integerLength(0...6)))
        scoreLabel.position = CGPoint(x: 0, y: 0)
        addChild(scoreLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
