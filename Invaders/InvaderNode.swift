//
//  InvaderNode.swift
//  Invaders
//
//  Created by Julien Marusi on 09/02/2017.
//  Copyright © 2017 Julien Marusi. All rights reserved.
//

import SpriteKit

class InvaderNode: SKNode
{
    private var moveStep: CGFloat = 20
    private var visuels = Array<SKSpriteNode>()

    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(maxWidth: CGFloat, type: Int)
    {
        super.init()
        
        moveStep = maxWidth
        initNodeGraph(maxWidth: maxWidth, type: type)
    }

    private func initNodeGraph(maxWidth: CGFloat, type: Int)
    {
        let sprite_size: CGSize = CGSize(width: maxWidth, height: maxWidth)
        
        var sprite_visuel = SKSpriteNode(imageNamed: "i\(type)_1")
        sprite_visuel.scale(to: sprite_size)
        visuels.append(sprite_visuel)
        
        sprite_visuel = SKSpriteNode(imageNamed: "i\(type)_2")
        sprite_visuel.scale(to: sprite_size)
        sprite_visuel.isHidden = true
        visuels.append(sprite_visuel)

        self.addChild(visuels[0])
        self.addChild(visuels[1])
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

    func calculateNewPosition(dir: String)
    {
        if (visuels[1].isHidden) {
            visuels[0].isHidden = true
            visuels[1].isHidden = false
        }
        else {
            visuels[0].isHidden = false
            visuels[1].isHidden = true
        }

        switch(dir)
        {
            case "right":
                position.x += moveStep
            case "left":
                position.x -= moveStep
            case "down_left", "down_right":
                position.y -= moveStep
            default: break
        }
    }
}
