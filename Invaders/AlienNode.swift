//
//  InvaderNode.swift
//  Invaders
//
//  Created by Julien Marusi on 09/02/2017.
//  Copyright © 2017 Julien Marusi. All rights reserved.
//

import SpriteKit

class AlienNode: InvadersNode
{
    var anims = Array<SKTexture>()
    var textureNum: Int = 0
    let alienExplode: SKTexture = GlobalTextureAtlas.textureNamed("explode3")
    var isAlive = true
    var value = 0
    var GridCol: Int = 0
    var GridRow: Int = 0

    internal override func initNodeGraph(maxWidth: CGFloat, type: Int?)
    {
        self.maxWidth = ceil(maxWidth)
        self.maxHeight = ceil(maxWidth)
        let sprite_size = CGSize(width: self.maxWidth, height: self.maxHeight)
        
        anims.append(GlobalTextureAtlas.textureNamed("i\(type!)_1"))
        anims.append(GlobalTextureAtlas.textureNamed("i\(type!)_2"))
        
        self.texture = anims[0]
        self.scale(to: sprite_size)
        self.zPosition = 1
        
        let body = SKPhysicsBody(rectangleOf: sprite_size)
        body.isDynamic = true
        body.affectedByGravity = false
        body.categoryBitMask = AlienCategory
        body.contactTestBitMask = PlayerShootCategory
        body.collisionBitMask = 0
        body.fieldBitMask = 0
        body.mass = 0
        self.physicsBody = body

        self.moveStep = 10
        
        switch(type!) {
            case 1:
                value = 30
            case 2:
                value = 20
            case 3:
                value = 10
            default:
                value = 0
        }
        
//        drawCircleAt(CGPoint.zero, color: .red)
    }
    
    func setGridCoord(col: Int, row: Int)
    {
        self.GridCol = col
        self.GridRow = row
    }
    
    func drawCircleAt(_ loc: CGPoint, color: UIColor)
    {
        let path = CGMutablePath()
        path.addArc(center: loc, radius: 2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        let ball = SKShapeNode(path: path)
        ball.lineWidth = 1
        ball.fillColor = color
        ball.strokeColor = color
        
        self.addChild(ball)
    }

    func computeDirection(frame: CGRect, actual: String) -> String
    {
        switch(actual)
        {
            case "right":
                if (position.x + moveStep > frame.maxX - moveStep) {
                    return "down_left"
                }
            case "left":
                if (position.x - moveStep < frame.minX + moveStep) {
                    return "down_right"
                }
            case "down_left":
                return "left"
            case "down_right":
                return "right"
            default:
                return actual
        }
        
        return actual
    }
    
    override func getValue() -> Int
    {
        return self.value
    }

    func doNewPosition(dir: String) -> Bool
    {
        if isAlive {
            if (self.textureNum == 0) {
                self.texture = anims[1]
                self.textureNum = 1
            }
            else {
                self.texture = anims[0]
                self.textureNum = 0
            }

            switch(dir)
            {
                case "right":
                    position.x += self.moveStep
                case "left":
                    position.x -= self.moveStep
                case "down_left", "down_right":
                    position.y -= self.moveStep * 2
                    return true
                default: break
            }
        }
        return false
    }
    
    override func handleContact(contact: CGPoint, with object: SKPhysicsBody)
    {
        isAlive = false
        self.texture = alienExplode
        
        let explodeDone = SKAction.removeFromParent()
        let wait = SKAction.wait(forDuration: TimeInterval(0.1))
        
        self.run(SKAction.sequence([wait, explodeDone]))
        self.run(SKAction.sequence([wait, explodeDone]))
    }
}
