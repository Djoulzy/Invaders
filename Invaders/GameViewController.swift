//
//  GameViewController.swift
//  Invaders
//
//  Created by Julien Marusi on 09/02/2017.
//  Copyright © 2017 Julien Marusi. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

var GlobalTextureAtlas = SKTextureAtlas()

class GameViewController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTextureAtlas()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = GameScene(size: view.bounds.size)
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill

            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    private func initTextureAtlas()
    {
        var globalImage = [String: UIImage]()
        
        for index in 1...3 {
            let tmpImg1 = UIImage(named: "i\(index)_1")
            let tmpImg2 = UIImage(named: "i\(index)_2")
            let tmpImg3 = UIImage(named: "tir\(index)")
            let tmpImg4 = UIImage(named: "explode\(index)")

            globalImage["i\(index)_1"] = tmpImg1
            globalImage["i\(index)_2"] = tmpImg2
            globalImage["tir\(index)"] = tmpImg3
            globalImage["explode\(index)"] = tmpImg4
        }

        let playerShip = UIImage(named: "player")
        globalImage["player"] = playerShip
        
        GlobalTextureAtlas = SKTextureAtlas(dictionary: globalImage)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
