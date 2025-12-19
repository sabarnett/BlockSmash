//
// -----------------------------------------
// Original project: BlockSmash
// Original package: BlockSmash
// Created on: 19/12/2025 by: Steven Barnett
// Web: http://www.sabarnett.co.uk
// GitHub: https://www.github.com/sabarnett
// -----------------------------------------
// Copyright © 2025 Steven Barnett. All rights reserved.
//

import SpriteKit

class CountdownNode: SKSpriteNode {

    let fuel: SKSpriteNode
    var maskNode: SKSpriteNode

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {

        // Fuel gradient is anchored on the left
        fuel = SKSpriteNode(imageNamed: "FuelGuage")
        fuel.anchorPoint = CGPoint(x: 0, y: 0.5)

        // The mask matches the size of the fuel. The colour
        // does not matter as it is only a mask for the Crop Node
        maskNode = SKSpriteNode(color: .white, size: fuel.size)
        maskNode.anchorPoint = CGPoint(x: 0, y: 0.5)

        super.init(texture: texture, color: color, size: size)
        self.anchorPoint = .zero

        let cropNode = SKCropNode()
        cropNode.maskNode = maskNode
        cropNode.addChild(fuel)
        cropNode.position = CGPoint(x: 0, y: 0)
        addChild(cropNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func percentRemaining(_ remaining: Double) {
        maskNode.size.width = fuel.size.width * remaining
    }
}
