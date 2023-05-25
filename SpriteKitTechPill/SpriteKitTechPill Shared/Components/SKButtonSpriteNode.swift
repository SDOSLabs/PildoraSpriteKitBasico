//
//  SKButtonSpriteNode.swift
//  SpriteKitTechPill iOS
//
//  Created by Juan Fuentes on 22/5/23.
//

import SpriteKit

protocol SKButtonSpriteNodeDelegate {
    func didPushButton(_sender: SKButtonSpriteNode)
}

class SKButtonSpriteNode: SKSpriteNode {
    var delegate: SKButtonSpriteNodeDelegate?
    var buttonType: Utils.RootSceneButtons?
    var pressed: Bool = false
    
    override var isUserInteractionEnabled: Bool {
        set {}
        get {
            return true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressed = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressed = false
        
        for t in touches {
            if let parent = self.parent,
               self.contains(t.location(in: parent)) {
                delegate?.didPushButton(_sender: self)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressed = false
    }
}
