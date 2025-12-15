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

class ScoreTitleNode: SKNode {

    var scoreLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")

    override init() {
        super.init()

        scoreLabel.fontSize = 36
        scoreLabel.fontColor = .black
        scoreLabel.text = "Score"
        addChild(scoreLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
