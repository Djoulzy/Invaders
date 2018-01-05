//
//  ShieldNode.swift
//  Invaders
//
//  Created by Julien Marusi on 27/02/2017.
//  Copyright © 2017 Julien Marusi. All rights reserved.
//

import SpriteKit

class ShieldNode: InvadersNode
{
    var ShieldPath = UIBezierPath()
    var shieldImage: CGImage?
    var shieldNum: Int = 0
    
    private var context: CGContext?
    private var colorSpace: CGColorSpace?
    private var bitmapInfo: CGBitmapInfo?
    private var dataContext: UnsafeMutableRawPointer?

    private var ShootInShieldContact = Array<SKNode>()
    
    private struct ColorPoint
    {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
    }
    
    internal override func initNodeGraph(maxWidth: CGFloat, type: Int?)
    {
        self.maxWidth = ceil(maxWidth*3)
        self.maxHeight = ceil(maxWidth*2.5)

        self.colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapBytesPerRow = Int(self.maxWidth) * 4
        self.bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        self.context = CGContext(data: nil, width: Int(self.maxWidth), height: Int(self.maxHeight), bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: self.colorSpace!, bitmapInfo: self.bitmapInfo!.rawValue)
        self.dataContext = self.context!.data
        
        self.shieldImage = drawShield(ctx: self.context!, maxWidth: self.maxWidth, maxHeight: self.maxHeight)
        self.size = CGSize(width: self.maxWidth, height: self.maxHeight)
        self.anchorPoint = CGPoint.zero
        self.zPosition = 0
        self.texture = SKTexture(cgImage: self.shieldImage!)

//        let body = SKPhysicsBody(texture: self.texture!, size: CGSize(width: self.maxWidth, height: self.maxHeight))
//        body.isDynamic = true
//        body.affectedByGravity = false
//        body.categoryBitMask = ShieldCategory
//        body.contactTestBitMask = AlienShootCategory
//        body.collisionBitMask = 0
//        body.fieldBitMask = 0
//        body.usesPreciseCollisionDetection = true
//        body.mass = 0
//        self.physicsBody = body
//        drawRepere(color: .white)
    }
    
    private func drawShield(ctx: CGContext, maxWidth: CGFloat, maxHeight: CGFloat) -> CGImage?
    {
        let corner = maxHeight/3.5
        let feet = maxWidth/3.5
        let feetCorner = feet/3.5

        ctx.beginPath()
        ctx.move(to: CGPoint(x:0, y:0))
        ctx.addLine(to: CGPoint(x:0, y:(maxHeight - corner)))
        ctx.addLine(to: CGPoint(x:corner, y:maxHeight))
        ctx.addLine(to: CGPoint(x:(maxWidth - corner), y:maxHeight))
        ctx.addLine(to: CGPoint(x:maxWidth, y:(maxHeight - corner)))
        ctx.addLine(to: CGPoint(x:maxWidth, y:0))
        ctx.addLine(to: CGPoint(x:(maxWidth - feet), y:0))
        ctx.addLine(to: CGPoint(x:(maxWidth - feet), y:(feet - feetCorner)))
        ctx.addLine(to: CGPoint(x:(maxWidth - feet - feetCorner), y:feet))
        ctx.addLine(to: CGPoint(x:(feet + feetCorner), y:feet))
        ctx.addLine(to: CGPoint(x:feet, y:(feet - feetCorner)))
        ctx.addLine(to: CGPoint(x:feet, y:0))
        ctx.closePath()
        
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.setStrokeColor(UIColor.white.cgColor)
        ctx.fillPath()
        
        return ctx.makeImage()
    }
    
    func drawCircleAt(_ loc: CGPoint, color: UIColor)
    {
        let path = CGMutablePath()
        path.addArc(center: loc, radius: 2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        let ball = SKShapeNode(path: path)
        ball.lineWidth = 1
        ball.fillColor = color
        ball.strokeColor = color
        ball.zPosition = 10
        
        self.addChild(ball)
    }

    func drawRepere(color: UIColor)
    {
        let path = CGMutablePath()
        path.move(to: CGPoint(x:0, y: -maxHeight))
        path.addLine(to: CGPoint(x:0, y:maxHeight))
        path.move(to: CGPoint(x: -maxWidth, y:0))
        path.addLine(to: CGPoint(x:maxWidth, y:0))
        path.addRect(CGRect(origin: CGPoint.zero, size: CGSize(width: maxWidth, height: maxHeight)))
        
        let rep = SKShapeNode(path: path)
        rep.lineWidth = 1
        rep.strokeColor = color
        
        self.addChild(rep)
    }
    
//    func drawCircleAt(_ loc: CGPoint, color: UIColor)
//    {
//        let path = CGMutablePath()
//        path.addArc(center: loc, radius: 2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
//        
//        let ball = SKShapeNode(path: path)
//        ball.lineWidth = 1
//        ball.fillColor = color
//        ball.strokeColor = color
//        
//        self.addChild(ball)
//    }

    private func getColorAt(pos: CGPoint) -> ColorPoint
    {
        let offset = 4 * (Int(pos.y) * Int(self.maxWidth) + Int(pos.x))
        
//        let alpha = CGFloat(dataContext!.load(fromByteOffset: offset, as: UInt8.self)) / 255.0
        let red = CGFloat(dataContext!.load(fromByteOffset: offset+1, as: UInt8.self)) / 255.0
        let green = CGFloat(dataContext!.load(fromByteOffset: offset+2, as: UInt8.self)) / 255.0
        let blue = CGFloat(dataContext!.load(fromByteOffset: offset+3, as: UInt8.self)) / 255.0
        
        let color = ColorPoint(red: red, green: green, blue: blue)
        
        return color
    }
    
    private func testColor(_ pos: CGPoint)
    {
        for y in 0...Int(self.maxHeight)-1 {
            var str = String()
            for x in 0...Int(self.maxWidth)-1 {
                let color = getColorAt(pos: CGPoint(x: x, y: y))
                if (Int(pos.x) == x && Int(pos.y) == y) {
                    str.append("X")
                }
                else {
                    let val = Int(color.red)
                    if (val == 0) { str.append(" ") }
                    else { str.append(".") }
                }
            }
            print(str)
        }
    }

    func addImpact(impact: CGPoint, sourceView: UIView) -> Bool
    {
//        let inImagePos = CGPoint(x: impact.x - (maxWidth/2), y: impact.y - (maxHeight/2))
//        self.context!.draw(self.shieldImage!, in: CGRect(origin: CGPoint.zero, size: self.size), byTiling: false)
        let inImagePos = CGPoint(x: impact.x, y: maxHeight - impact.y)

        let color = self.getColorAt(pos: inImagePos)

        if (color.red != 0 && color.green != 0 && color.blue != 0) {
            self.context!.addArc(center: impact, radius: 10, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            self.context!.setFillColor(UIColor.black.cgColor)
            self.context!.fillPath()
            self.context!.flush()

            self.shieldImage = self.context!.makeImage()
            self.texture = SKTexture(cgImage: self.shieldImage!)
            return true
        }
//        else {
//            drawCircleAt(impact, color: .red)
//            testColor(inImagePos)
//            print("Color: \(color), Impact: \(impact)")
//        }

        return false
    }
}
