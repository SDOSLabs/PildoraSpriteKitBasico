//
//  GameViewController.swift
//  SpriteKitTechPill iOS
//
//  Created by Juan Fuentes on 14/5/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let view = self.view as! SKView? {
            if let scene = SKScene(fileNamed: "RootScene") {
                scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
                
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
