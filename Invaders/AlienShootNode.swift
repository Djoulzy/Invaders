//
//  AlienShootNode.swift
//  Invaders
//
//  Created by Julien Marusi on 10/02/2017.
//  Copyright © 2017 Julien Marusi. All rights reserved.
//

import SpriteKit

class AlienShootNode: InvadersNode
{
    var anims = Array<SKTexture>()

    internal override func initNodeGraph(maxWidth: CGFloat, type: Int?)
    {
        self.maxWidth = ceil(maxWidth/2)
        self.maxHeight = ceil(maxWidth/1.5)
        let sprite_size: CGSize = CGSize(width: self.maxWidth, height: self.maxHeight)

        anims.append(GlobalTextureAtlas.textureNamed("tir1"))
        anims.append(GlobalTextureAtlas.textureNamed("tir2"))

        self.texture = GlobalTextureAtlas.textureNamed("tir1")
        self.size = sprite_size
        
        let body = SKPhysicsBody(rectangleOf: sprite_size)
        body.isDynamic = true
        body.affectedByGravity = false
        body.categoryBitMask = AlienShootCategory
        body.contactTestBitMask = PlayerCategory | PlayerShootCategory
        body.collisionBitMask = 0
        body.usesPreciseCollisionDetection = true
        body.fieldBitMask = 0
        body.mass = 0
        self.physicsBody = body
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
    
    func shootAction(from start: CGPoint, to destination: CGPoint)
    {
        let duration = TimeInterval(2)
        let timePerFrame = TimeInterval(0.2)
        let count = (duration/(timePerFrame*2))
        
        self.position = start

        let move = SKAction.move(to: destination, duration: duration)
        let moveDone = SKAction.removeFromParent()
        
        let animation = SKAction.animate(with: self.anims, timePerFrame: timePerFrame)
        let repeatAnim = SKAction.repeat(animation, count: Int(count));
        
        self.run(repeatAnim)
        self.run(SKAction.sequence([move, moveDone]))
    }
    
    override func handleContact(contact: CGPoint, with object: SKPhysicsBody)
    {
        self.removeFromParent()
    }
}
