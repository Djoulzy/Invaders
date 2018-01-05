//
//  GameScene.swift
//  Invaders
//
//  Created by Julien Marusi on 09/02/2017.
//  Copyright © 2017 Julien Marusi. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    private var invadersGrid = Array<Array<Bool>>()
    private var alienNodes = SKNode()
    private var invaderShoots = SKNode()
    private var playerNode = PlayerNode()
    private let playerShoots = SKNode()
    private var alienCanShoot = Array<AlienNode>()
    private var shields = SKNode()

    private var direction: String = "right"
    
    private var AlienBox: CGFloat = 0.0
    private let spacing: Int = 30
    private let nbAliensPerLine: Int = 11
    
    private var zoneLeft = CGRect()
    private var zoneRight = CGRect()
    private var zoneShoot = CGRect()
    
    private var touchEnabled: String?
    
    private var LevelNumber: Int = 0
    private var PlayerLive: Int = 3
    private var PlayerLiveSprite = Array<SKSpriteNode>()
    private var PlayerIsDead = false
    private var levelIsOver = false
    private var score: Int = 0
    private let scoreDisplay = SKLabelNode(fontNamed: "Space Invaders")
    private let liveDisplay = SKLabelNode(fontNamed: "Space Invaders")
    
    private var lowBorderScreenY: CGFloat = 0
    private var highBorderScreenY: CGFloat = 0
    private var quadran: CGFloat = 0
    
    private var alienSpeed: Double = 1
    
    private struct ShieldZone
    {
        var area: CGRect?
        var sprite: ShieldNode?
        
        init(shield: ShieldNode?)
        {
            sprite = shield
            if let newShield = shield {
                area = CGRect(origin: newShield.position, size: CGSize(width: newShield.maxWidth, height: newShield.maxHeight))
            }
        }
    }
    
    private var shieldZoneList = Array<ShieldZone>()
    
    override convenience init(size: CGSize) {
        self.init(size: size, param: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(size: CGSize, param: Int)
    {
        super.init(size: size)
    
//        let fontFamilyNames = UIFont.familyNames
//        for familyName in fontFamilyNames {
//            //Check the Font names of the Font Family
//            let names = UIFont.fontNames(forFamilyName: familyName )
//            // Write out the Font Famaily name and the Font's names of the Font Family
//            print("Font == \(familyName) \(names)")
//        }
        
        AlienBox = frame.maxX / CGFloat(Int(CGFloat(nbAliensPerLine + 3)*1.8))
        
        backgroundColor = SKColor.black
        
        quadran = frame.maxX/3
        zoneLeft = CGRect(x: 0, y: 0, width: quadran, height: 150)
        zoneRight = CGRect(x: quadran, y: 0, width: quadran, height: 150)
        zoneShoot  = CGRect(x: frame.maxX - quadran, y: 0, width: quadran, height: 150)
        
        lowBorderScreenY = 190
        highBorderScreenY = frame.maxY-70
        
        physicsWorld.contactDelegate = self

        self.invadersGrid = Array(repeating: Array(repeating: true, count: nbAliensPerLine), count: 5)
        addChild(playerShoots)
        addChild(invaderShoots)
        addChild(shields)
        addChild(alienNodes)
    
        InitLevel()
    }
    
    func drawCircleAt(_ loc: CGPoint, color: UIColor)
    {
        let path = CGMutablePath()
        path.addArc(center: loc, radius: 4, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        let ball = SKShapeNode(path: path)
        ball.lineWidth = 1
        ball.fillColor = color
        ball.strokeColor = color
        ball.zPosition = 10
        
        self.addChild(ball)
    }
    
    private func drawControls()
    {
        let scoreLabel = SKLabelNode(fontNamed: "Space Invaders")
        scoreLabel.text = "SCORE<1>        HI-SCORE"
        scoreDisplay.text = "0000"
        liveDisplay.text = "\(PlayerLive)"
        scoreLabel.fontSize = 20;
        scoreDisplay.fontSize = 20;
        liveDisplay.fontSize = 20;
        scoreLabel.position = CGPoint(x: 150, y: highBorderScreenY+40)
        scoreDisplay.position = CGPoint(x: 80, y: highBorderScreenY+10)
        liveDisplay.position = CGPoint(x: 20, y: lowBorderScreenY-30)
        addChild(scoreLabel)
        addChild(scoreDisplay)
        addChild(liveDisplay)
        
        var linearShapeNode = SKShapeNode(rect: zoneLeft)
        addChild(linearShapeNode)
        linearShapeNode = SKShapeNode(rect: zoneRight)
        addChild(linearShapeNode)
        linearShapeNode = SKShapeNode(rect: zoneShoot)
        addChild(linearShapeNode)
        linearShapeNode = SKShapeNode(rect: CGRect(x: 0, y: lowBorderScreenY, width: frame.maxX, height: 2))
        linearShapeNode.lineWidth = 2.0;
        addChild(linearShapeNode)
        
        for sprite in 0...(PlayerLive-1) {
            let tmpNode = SKSpriteNode(texture: GlobalTextureAtlas.textureNamed("player"))
            tmpNode.position = CGPoint(x: CGFloat(50 + (sprite*30)), y: lowBorderScreenY-20)
            tmpNode.scale(to: CGSize(width: (AlienBox+10), height: (AlienBox+10)))
            self.addChild(tmpNode)
            PlayerLiveSprite.append(tmpNode)
        }
    }

    private func addAlien(alienType: Int, col: Int, line: Int)
    {
        let tmp = AlienNode(maxWidth: AlienBox, type: alienType)
        tmp.position = CGPoint(x: frame.origin.x + CGFloat(spacing*col), y: frame.maxY - 100 - (AlienBox * CGFloat(Double(line+1) * 1.5)))
        tmp.setGridCoord(col: col-1, row: line)
        alienNodes.addChild(tmp)
    }

    private func InitLevel()
    {
        LevelNumber += 1

        for index in 1...nbAliensPerLine
        {
            addAlien(alienType: 1, col: index, line: 0)
            addAlien(alienType: 2, col: index, line: 1)
            addAlien(alienType: 2, col: index, line: 2)
            addAlien(alienType: 3, col: index, line: 3)
            addAlien(alienType: 3, col: index, line: 4)
        }
        
        let startShieldX = CGFloat(quadran/2) - ceil(AlienBox*1.5)
        for index in 0...2
        {
            let tmpShield = ShieldNode(maxWidth: AlienBox, type: nil)
            tmpShield.position = CGPoint(x: (quadran*CGFloat(index))+startShieldX, y: frame.minY + 250)
            tmpShield.shieldNum = index
            shields.addChild(tmpShield)
            shieldZoneList.append(ShieldZone(shield: tmpShield))
        }

        drawControls()
    }
    
    func startLevel()
    {
        PlayerLive -= 1
        if (PlayerLive >= 0)
        {
            PlayerIsDead = false

            playerNode = PlayerNode(maxWidth: AlienBox, type: nil)
            playerNode.position = CGPoint(x: frame.midX, y: frame.minY + 230)
            addChild(playerNode)
            PlayerLiveSprite[PlayerLive].removeFromParent()

            let wait = SKAction.wait(forDuration: 1)
            run(wait, completion: {
                [unowned self] in self.gameTimedAction()
            })
        }
        else
        {
            let gameover = SKLabelNode(fontNamed: "Space Invaders")
            gameover.text = "GAME OVER"
            gameover.fontSize = 50;
            gameover.position = CGPoint(x: frame.midX, y: frame.midY)
            addChild(gameover)
            PlayerLiveSprite.removeAll()
        }
    }
    
    private func computeAlienDirection() -> String
    {
        var tmp = direction
        
        for index in alienNodes.children as! [AlienNode]
        {
            tmp = index.computeDirection(frame: frame, actual: direction)
            if (tmp != direction) {
                return tmp
            }
        }
        return tmp
    }
    
    private func moveAlien()
    {
        var down = false
        for index in alienNodes.children as! [AlienNode]
        {
            down = index.doNewPosition(dir: direction)
            if (index.position.y < frame.minY + 250 + ceil(AlienBox*2.5)) {
                shields.removeAllChildren()
            }
            if (index.position.y < lowBorderScreenY) {
                playerDeath()
            }
        }
        if down {
            if alienSpeed > 0.4 {
                alienSpeed = alienSpeed - 0.075
            }
        }
    }
    
    private func doAlienShoot()
    {
        if (invaderShoots.children.count == 0) {
            let witch = Int(arc4random_uniform(UInt32(alienCanShoot.count)))
            let newShoot = AlienShootNode(maxWidth: AlienBox, type: nil)
            newShoot.shootAction(from: CGPoint(x: alienCanShoot[witch].frame.midX, y: alienCanShoot[witch].frame.maxY), to: CGPoint(x: alienCanShoot[witch].frame.midX, y: lowBorderScreenY))
            invaderShoots.addChild(newShoot)
        }
    }
    
    private func doPlayerShoot()
    {
        if (playerShoots.children.count == 0) {
            let newShoot: PlayerShootNode = PlayerShootNode(maxWidth: AlienBox, type: nil)
            newShoot.shootAction(from: CGPoint(x: playerNode.frame.midX, y: playerNode.frame.maxY), to: CGPoint(x: playerNode.frame.midX, y: highBorderScreenY))
            playerShoots.addChild(newShoot)
        }
    }

    func playerDeath()
    {
        PlayerIsDead = true
        
        let wait = SKAction.wait(forDuration: 4)
        run(wait, completion: {
            [unowned self] in self.startLevel()
        })
    }

    func gameTimedAction()
    {
        if (!PlayerIsDead) {
            direction = computeAlienDirection()
            moveAlien()

            if (invaderShoots.children.count < 3) {
                doAlienShoot()
            }
        }
        
        let wait = SKAction.wait(forDuration: alienSpeed)
//        print("\(alienSpeed)")
        run(wait, completion: {
            [unowned self] in self.gameTimedAction()
        })
    }
    
    private func doContactAction(producer: SKPhysicsBody, receiver: SKPhysicsBody, contact: CGPoint, start: Bool)
    {
        if let object = producer.node
        {
            object.handleContact(contact: contact, with: receiver)
            switch(producer.categoryBitMask)
            {
                case AlienCategory:
                    if start {
                        score += object.getValue()
                    }
                    break
                case PlayerCategory:
                    if start {
                        playerDeath()
                    }
                    break
                default: break
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        doContactAction(producer: contact.bodyA, receiver: contact.bodyB, contact: contact.contactPoint, start: true)
        doContactAction(producer: contact.bodyB, receiver: contact.bodyA, contact: contact.contactPoint, start: true)
    }
    
    func didEnd(_ contact: SKPhysicsContact) {

    }

    func touchDown(atPoint pos : CGPoint)
    {
        if !PlayerIsDead
        {
            if (zoneLeft.contains(pos)) {
                touchEnabled = "left"
                playerNode.calculateNewPosition(dir: "left", frame: frame)
            }
            if (zoneRight.contains(pos)) {
                touchEnabled = "right"
                playerNode.calculateNewPosition(dir: "right", frame: frame)
            }
            if (zoneShoot.contains(pos)) {
                touchEnabled = nil
                doPlayerShoot()
        }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint)
    {
        if touchEnabled != nil {
            if (zoneLeft.contains(pos)) {
                touchEnabled = "left"
                playerNode.calculateNewPosition(dir: "left", frame: frame)
            }
            if (zoneRight.contains(pos)) {
                touchEnabled = "right"
                playerNode.calculateNewPosition(dir: "right", frame: frame)
            }
            if (zoneShoot.contains(pos)) {
                touchEnabled = nil
                doPlayerShoot()
            }
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        touchEnabled = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    override func didMove(to: SKView)
    {
        startLevel()
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        // Called before each frame is rendered
        if touchEnabled != nil {
            playerNode.calculateNewPosition(dir: touchEnabled!, frame: frame)
        }
        
        for ashoots in invaderShoots.children as! [AlienShootNode] {
            for shield in shieldZoneList {
                if shield.area!.contains(ashoots.position) {
                    if shield.sprite!.addImpact(impact: convert(ashoots.position, to: shield.sprite!), sourceView: self.view!) {
                        ashoots.removeFromParent()
                    }
                }
            }
        }
        
        alienCanShoot.removeAll()
        for alien in alienNodes.children as! [AlienNode] {
            var canShoot = true
            if (alien.GridRow < 4) {
                for index in (alien.GridRow+1)...4 {
                    if (self.invadersGrid[index][alien.GridCol] == true) {
                        canShoot = false
                        break
                    }
                }
            }

            if canShoot {
                alienCanShoot.append(alien)
            }
        }

        scoreDisplay.text = String(format: "%05d", score)
        if (PlayerLive >= 0) {
            liveDisplay.text = "\(PlayerLive)"
        }
        else {
            liveDisplay.removeFromParent()
        }
        
        if (alienCanShoot.count == 0) {
            levelIsOver = true
        }
    }
}
