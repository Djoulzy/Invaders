//
//  PlayerNode.swift
//  Invaders
//
//  Created by Julien Marusi on 10/02/2017.
//  Copyright © 2017 Julien Marusi. All rights reserved.
//

import SpriteKit

class PlayerNode: InvadersNode
{
    var anims = Array<SKTexture>()

    internal override func initNodeGraph(maxWidth: CGFloat, type: Int?)
    {
        self.maxWidth = ceil(maxWidth)
        self.maxHeight = ceil(maxWidth)
        let sprite_size = CGSize(width: self.maxWidth, height: self.maxHeight)
        
        anims.append(GlobalTextureAtlas.textureNamed("explode1"))
        anims.append(GlobalTextureAtlas.textureNamed("explode2"))
        
        self.texture = GlobalTextureAtlas.textureNamed("player")
        self.scale(to: sprite_size)

        let body = SKPhysicsBody(rectangleOf: sprite_size)
        body.isDynamic = true
        body.affectedByGravity = false
        body.categoryBitMask = PlayerCategory
        body.contactTestBitMask = AlienShootCategory | AlienCategory
        body.collisionBitMask = 0
        body.fieldBitMask = 0
        body.mass = 0
        self.physicsBody = body
        
        self.moveStep = 5
    }
    
    func calculateNewPosition(dir: String, frame: CGRect)
    {
        switch(dir)
        {
        case "right":
            if (position.x + self.moveStep < frame.maxX-10) {
                position.x += self.moveStep
            }
        case "left":
            if (position.x - self.moveStep > frame.minX+10) {
                position.x -= self.moveStep
            }
        default: break
        }
    }
    
    override func handleContact(contact: CGPoint, with object: SKPhysicsBody)
    {
        let duration = TimeInterval(4)
        let timePerFrame = TimeInterval(0.2)
        let count = (duration/(timePerFrame*2))

        let animation = SKAction.animate(with: self.anims, timePerFrame: timePerFrame)
        let repeatAnim = SKAction.repeat(animation, count: Int(count));
        let moveDone = SKAction.removeFromParent()
        let wait = SKAction.wait(forDuration: duration)
        
        self.run(SKAction.sequence([repeatAnim, moveDone]))
        self.run(SKAction.sequence([wait, moveDone]))
    }
}
