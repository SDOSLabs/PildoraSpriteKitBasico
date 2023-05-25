//
//  RootScene.swift
//  SpriteKitTechPill iOS
//
//  Created by Juan Fuentes on 14/5/23.
//

import SpriteKit

class RootScene: SKScene {
    private var playGameNodeButton: SKButtonSpriteNode?
    private var playGamePhyscisButton: SKButtonSpriteNode?
    private var playGameContactsButton: SKButtonSpriteNode?
    
    override func didMove(to view: SKView) {
        self.playGameNodeButton = childNode(withName: "NodeButton") as? SKButtonSpriteNode
        self.playGameNodeButton?.buttonType = .nodeGame
        self.playGamePhyscisButton = childNode(withName: "PhysicsButton") as? SKButtonSpriteNode
        self.playGamePhyscisButton?.buttonType = .physicsGame
        self.playGameContactsButton = childNode(withName: "ContactButton") as? SKButtonSpriteNode
        self.playGameContactsButton?.buttonType = .contactGame
        
        self.playGameNodeButton?.delegate = self
        self.playGamePhyscisButton?.delegate = self
        self.playGameContactsButton?.delegate = self
    }
    
    private func loadScene(scenetype: Utils.RootSceneButtons = .other) {
        let transion = SKTransition.reveal(with: .left, duration: 1)
        if scenetype != .other {
            let sceneName = scenetype.rawValue
            if let newScene = SKScene(fileNamed: sceneName.appending("Scene")),
               let view = self.view {
                newScene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
                view.presentScene(newScene, transition: transion)
            }
        }
    }
}

extension RootScene: SKButtonSpriteNodeDelegate {
    func didPushButton(_sender sender: SKButtonSpriteNode) {
        if let buttonType = sender.buttonType {
            self.loadScene(scenetype: buttonType)
        }
    }
}
