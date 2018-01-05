//
//  ShootNode.swift
//  Invaders
//
//  Created by Julien Marusi on 14/02/2017.
//  Copyright © 2017 Julien Marusi. All rights reserved.
//

import SpriteKit

extension SKNode
{
    func handleContact(contact: CGPoint, with object: SKPhysicsBody) {
    }
    
    func getValue() -> Int {
        return 0
    }
}

class InvadersNode: SKSpriteNode
{
    var maxWidth: CGFloat = 0
    var maxHeight: CGFloat = 0
    var moveStep: CGFloat = 20
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(maxWidth: CGFloat, type: Int?)
    {
        self.init(texture: nil, color: UIColor.black, size: CGSize(width: maxWidth, height: maxWidth))
        initNodeGraph(maxWidth: maxWidth, type: type)
    }
    
    func initNodeGraph(maxWidth: CGFloat, type: Int?)
    {
    }
}
