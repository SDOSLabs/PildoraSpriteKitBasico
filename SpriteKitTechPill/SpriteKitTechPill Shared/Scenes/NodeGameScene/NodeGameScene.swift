//
//  NodeGameScene.swift
//  SpriteKitTechPill iOS
//
//  Created by Juan Fuentes on 22/5/23.
//

import SpriteKit

class NodeGameScene: SKScene {
    /*
     En este minijuego, podremos comprobar como se añaden diferentes tipos de SKNode, Sprites y Shapes,
        asi como moverlos por la escena, con seguimiento del touch.
     */
    private var moneyNode: SKSpriteNode?
    private var walletNode: SKSpriteNode?
    private var closeButton: SKButtonSpriteNode?
    
    private var activeTouches : [UITouch : SKNode] = [:]
    
    override func didMove(to view: SKView) {
        self.moneyNode = childNode(withName: "money") as? SKSpriteNode
        self.walletNode = childNode(withName: "wallet") as? SKSpriteNode
        self.walletNode?.isUserInteractionEnabled = false
        self.closeButton = childNode(withName: "close") as? SKButtonSpriteNode
        self.closeButton?.delegate = self
        
        self.drawGameBodyLimits()
    }
}
// MARK: - Eventos Pantalla Tactil
extension NodeGameScene {
    // Eventos de la pantalla tactil
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(touch: t) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(touch: t) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(touch: t) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(touch: t) }
    }
    
    func touchDown(touch t: UITouch) {
        let location = t.location(in: self)
        
        let node = atPoint(location)
        
        if node == moneyNode {
            activeTouches[t] = createDragNode(linkedTo: node)
        }
    }
    
    func touchMoved(touch t: UITouch) {
        let location = t.location(in: self)
        
        if let node = activeTouches[t] {
            node.position = location
        }
    }
    
    func touchUp(touch t: UITouch) {
        if let node = activeTouches[t] {
            self.moneyNode?.physicsBody?.velocity.dx = 0.0
            self.moneyNode?.physicsBody?.velocity.dy = 0.0
            self.moneyNode?.physicsBody?.angularVelocity = 0.0
            node.removeFromParent()
        }
        
        activeTouches.removeValue(forKey: t)
    }
    
    func createDragNode(linkedTo money: SKNode) -> SKNode {
        let node = SKShapeNode(circleOfRadius: 20.0)
        node.position = money.position
        self.addChild(node)
        node.physicsBody = SKPhysicsBody()
        node.physicsBody?.node?.isUserInteractionEnabled = false
        node.physicsBody?.isDynamic = false
        
        if let moneyPhysicsBody = money.physicsBody,
           let nodePhysicsBody = node.physicsBody {
            let joint = SKPhysicsJointSpring.joint(withBodyA: moneyPhysicsBody, bodyB: nodePhysicsBody, anchorA: money.position, anchorB: node.position)
            joint.frequency = 100.0
            joint.damping = 10.0
            
            physicsWorld.add(joint)
        }
        
        return node
    }
}

extension NodeGameScene {
    private func drawGameBodyLimits() {
        let topLeft: CGPoint = CGPoint(x: self.frame.minX, y: self.frame.minY)
        let topRight: CGPoint = CGPoint(x: self.frame.maxX, y: self.frame.minY)
        
        let bottomLeft: CGPoint = CGPoint(x: self.frame.minX, y: self.frame.maxY)
        let bottomRight: CGPoint = CGPoint(x: self.frame.maxX, y: self.frame.maxY)
        
        let bodyPath: CGMutablePath = CGMutablePath()
        bodyPath.addLines(between: [topLeft, topRight, bottomRight, bottomLeft])
        
        let bodie: SKPhysicsBody = SKPhysicsBody(edgeLoopFrom: bodyPath)
        self.physicsBody = bodie
        self.physicsBody?.isDynamic = false
    }
}

extension NodeGameScene: SKButtonSpriteNodeDelegate {
    func didPushButton(_sender: SKButtonSpriteNode) {
        self.removeAllActions()
        self.removeAllChildren()
        
        let transition = SKTransition.reveal(with: .right, duration: 1)
        if let newScene = SKScene(fileNamed: "RootScene"),
           let view = self.view {
            newScene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
            view.presentScene(newScene, transition: transition)
        }
    }
}




