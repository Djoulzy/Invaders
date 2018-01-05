//
//  PlayerShootNode.swift
//  Invaders
//
//  Created by Julien Marusi on 13/02/2017.
//  Copyright © 2017 Julien Marusi. All rights reserved.
//

import SpriteKit

class PlayerShootNode: InvadersNode
{
    internal override func initNodeGraph(maxWidth: CGFloat, type: Int?)
    {
        self.maxWidth = 3
        self.maxHeight = ceil(maxWidth/1.5)
        let sprite_size = CGSize(width: self.maxWidth, height: self.maxHeight)

        self.texture = GlobalTextureAtlas.textureNamed("tir3")
        self.scale(to: sprite_size)
        
        let body = SKPhysicsBody(rectangleOf: sprite_size)
        body.isDynamic = true
        body.affectedByGravity = false
        body.categoryBitMask = PlayerShootCategory
        body.contactTestBitMask = AlienCategory
        body.collisionBitMask = 0
        body.fieldBitMask = 0
        body.mass = 0
        self.physicsBody = body
    }
    
    func shootAction(from start: CGPoint, to destination: CGPoint)
    {
        self.position = start
        let move = SKAction.move(to: destination, duration: TimeInterval(1))
        let moveDone = SKAction.removeFromParent()
        self.run(SKAction.sequence([move, moveDone]))
    }
    
    override func handleContact(contact: CGPoint, with object: SKPhysicsBody)
    {
        self.removeFromParent()
    }
}
