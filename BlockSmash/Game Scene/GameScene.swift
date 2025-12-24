//
//  GameScene.swift
//  BlockSmash
//
//  Created by Paul Hudson on 16/10/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit

@objcMembers
class GameScene: SKScene {

    let scoreLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
    let music = SKAudioNode(fileNamed: "winner-winner")
    let toolbar = ToolbarNode()
    var dataModel = SceneDataModel()
    let countdown = CountdownNode()

    let itemSize: CGFloat = 50
    let itemsPerColumn = 12
    let itemsPerRow = 18
    let itemImages = ["black", "blue", "green", "purple", "red", "yellow", "orange"]

    var popup: HighScoresPopup?
    var cols = [[Item]]()
    var currentMatches = Set<Item>()
    var gameStartTime: TimeInterval?
    var isGameOver = false
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "blocks")
        background.zPosition = -2
        addChild(background)

        toolbar.dataModel = dataModel
        toolbar.delegate = self
        toolbar.position = CGPoint(x: frame.maxX - 35, y: 0)
        addChild(toolbar)

        for x in 0 ..< itemsPerRow {
            var col = [Item]()

            for y in 0 ..< itemsPerColumn {
                let item = createItem(row: y, col: x, startOffScreen: true, canCreateBomb: false)
                col.append(item)
            }

            cols.append(col)
        }

        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: frame.maxX - 80, y: frame.maxY - 80)
        addChild(scoreLabel)

        score = 0

        countdown.position = CGPoint(x:  frame.minX + 60, y: frame.maxY - 70)
        addChild(countdown)

        if dataModel.playingSound {
            addChild(music)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        generateTouchIndicator(location: location)

        if isGameOver {
            // Play again pressed?
            if let _ = nodes(at: location).first(where: {$0.name == "playAgain"}) {
                if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                    dataModel.resetState()
                    scene.dataModel = dataModel
                    scene.scaleMode = .aspectFill
                    self.view?.presentScene(scene)
                }
            }
            return
        }

        guard let tappedItem = item(at: location) else { return }
        isUserInteractionEnabled = false
        currentMatches.removeAll()
        if dataModel.playingSound {
            run(SKAction.playSoundFileNamed("pop", waitForCompletion: false))
        }

        if tappedItem.name == "bomb" {
            triggerSpecialItem(tappedItem)
        }

        match(item: tappedItem)
        removeMatches()
        moveDown()

        adjustScore()
    }

    override func update(_ currentTime: TimeInterval) {
        if let gameStartTime = gameStartTime {
            let elapsed = currentTime - gameStartTime
//            let remaining = 3 - elapsed
            let remaining = 100 - elapsed

            let percentDone = max(0, CGFloat(remaining) / 100)
            countdown.percentRemaining(percentDone)

            if remaining <= 0 {
                endGame()
            }
        } else {
            gameStartTime = currentTime
        }
    }
    
    /// Useful when recording video. Places an indicator when the user taps.
    /// - Parameter location: The place the user tapped.
    func generateTouchIndicator(location: CGPoint) {
        if Constants.showTapIndicator == false { return }

        let indicator = SKShapeNode(circleOfRadius: 40)
        indicator.strokeColor = .blue
        indicator.fillColor = .blue
        indicator.alpha = 0.45
        indicator.position = location
        indicator.zPosition = 10

        addChild(indicator)

        let expand = SKAction.scale(to: 1.5, duration: 0.15)
        let contract = SKAction.scale(to: 0.6, duration: 0.15)
        let delete = SKAction.removeFromParent()
        let fadeOut = SKAction.fadeOut(withDuration: 0.15)
        indicator.run(
            SKAction.sequence(
                [
                    expand,
                    contract,
                    fadeOut,
                    delete
                ]
            )
        )
    }

    func position(for item: Item) -> CGPoint {
        let xOffset: CGFloat = -430
        let yOffset: CGFloat = -300

        let x = xOffset + itemSize * CGFloat(item.col)
        let y = yOffset + itemSize * CGFloat(item.row)
        return CGPoint(x: x, y: y)
    }

    func createItem(row: Int, col: Int, startOffScreen: Bool = false, canCreateBomb: Bool = true) -> Item {
        let itemImage: String

        if startOffScreen && canCreateBomb && Int.random(in: 0..<24) == 0 {
            itemImage = "bomb"
        } else {
            itemImage = itemImages.randomElement()!
        }

        let item = Item(imageNamed: itemImage)
        item.name = itemImage
        item.row = row
        item.col = col

        if startOffScreen {
            // 1: Calculate the position
            let finalPosition = position(for: item)

            // move it higher
            item.position = finalPosition
            item.position.y += 600

            // create an animation to move it to the final position
            let action = SKAction.move(to: finalPosition, duration: 0.5)

            // run the animation then re-enable user interaction when it finishes
            item.run(action) {
                self.isUserInteractionEnabled = true
            }
        } else {
            item.position = position(for: item)
        }

        addChild(item)
        return item
    }

    func item(at point: CGPoint) -> Item? {
        let items = nodes(at: point).compactMap { $0 as? Item }
        return items.first
    }

    func match(item original: Item) {
        var checkItems = [Item?]()

        currentMatches.insert(original)
        let pos = original.position

        checkItems.append(item(at: CGPoint(x: pos.x, y: pos.y - itemSize)))
        checkItems.append(item(at: CGPoint(x: pos.x, y: pos.y + itemSize)))
        checkItems.append(item(at: CGPoint(x: pos.x - itemSize, y: pos.y)))
        checkItems.append(item(at: CGPoint(x: pos.x + itemSize, y: pos.y)))

        for case let check? in checkItems {
            if currentMatches.contains(check) { continue }

            if check.name == original.name || original.name == "bomb" {
                match(item: check)
            }
        }
    }

    func removeMatches() {
        let sortedMatches = currentMatches.sorted {
            $0.row > $1.row
        }

        for item in sortedMatches {
            cols[item.col].remove(at: item.row)
            item.removeFromParent()
        }
    }

    func moveDown() {
        // move down any items that need it
        for (columnIndex, col) in cols.enumerated() {
            for (rowIndex, item) in col.enumerated() {
                item.row = rowIndex

                let action = SKAction.move(to: position(for: item), duration: 0.1)
                item.run(action)
            }

            while cols[columnIndex].count < itemsPerColumn {
                let item = createItem(row: cols[columnIndex].count, col: columnIndex, startOffScreen: true)
                cols[columnIndex].append(item)
            }
        }
    }

    func triggerSpecialItem(_ item: Item) {
        let flash = SKSpriteNode(color: .white, size: frame.size)
        flash.zPosition = -1
        addChild(flash)

        if dataModel.playingSound {
            run(SKAction.playSoundFileNamed("smart-bomb", waitForCompletion: false))
        }

        flash.run(SKAction.fadeOut(withDuration: 0.3)) {
            flash.removeFromParent()
        }
    }

    func penalizePlayer() {
        for col in cols {
            for item in col {
                let changeTo = itemImages.randomElement()!
                item.name = changeTo
                item.texture = SKTexture(imageNamed: changeTo)
            }
        }
    }

    func adjustScore() {
        let newScore = currentMatches.count

        if newScore == 1 {
            penalizePlayer()
        } else if newScore == 2 {
            // Do nothing
        } else {
            let matchCount = min(newScore, 16)
            let scoreToAdd = pow(2, Double(matchCount))
            score += Int(scoreToAdd)
        }
    }

    func endGame() {
        guard isGameOver == false else { return }
        isGameOver = true

        dataModel.highScores.add(score: score)

        let gameOver = SKSpriteNode(imageNamed: "game-over")
        gameOver.zPosition = 100
        addChild(gameOver)

        let playAgain = SKLabelNode(fontNamed: "Noteworthy-Bold")
        playAgain.text = "Tap to play again"
        playAgain.name = "playAgain"
        playAgain.zPosition = 100
        playAgain.position.y = gameOver.position.y - 190
        addChild(playAgain)

        music.removeFromParent()

        if dataModel.highScores.scoreAdded {
            showLeaderBoard()
        }
    }
}

// MARK: - Toolbar handling

extension GameScene: ToolbarDelegate {
    func showLeaderBoard() {
        let wasPaused = dataModel.gamePaused

        // Pause the game if it isn't already paused.
        if !wasPaused {
            playPause(isPaused: true)
        }

        popup = HighScoresPopup(scores: dataModel.highScores, latestScore: score) {
            // OnClose - toggle the game back on
            if !wasPaused {
                self.playPause(isPaused: false)
            }
            self.popup!.removeFromParent()
            self.popup = nil
        }
        popup!.position = CGPoint(x: 0, y: 0)
        popup!.zPosition = 9999

        addChild(popup!)
        popup!.show()
    }

    func playPause(isPaused: Bool) {
        if isPaused  == false {
            dataModel.gamePaused = false
            self.physicsWorld.speed = 1

            if dataModel.playingSound {
                addChild(music)
            }
        } else {
            dataModel.gamePaused = true
            self.physicsWorld.speed = 0

            if dataModel.playingSound {
                music.removeFromParent()
            }
        }
    }

    func playSound(turnOn: Bool) {
        if turnOn {
            addChild(music)
            dataModel.playingSound = true
        } else {
            music.removeFromParent()
            dataModel.playingSound = false
        }
    }
}
