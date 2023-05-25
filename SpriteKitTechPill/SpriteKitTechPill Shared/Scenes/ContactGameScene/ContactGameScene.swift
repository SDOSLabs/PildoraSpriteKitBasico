//
//  ContactGameScene.swift
//  SpriteKitTechPill iOS
//
//  Created by Juan Fuentes on 24/5/23.
//

import SpriteKit

class ContactGameScene: SKScene {
    private let limitsCategoryBitMask: UInt32 = 0b00001
    private let objectsCategoryBitMask: UInt32 = 0b0010
    
    private var numberOfTouches: Int = 0
    
    private var close: SKButtonSpriteNode?
    private var explosionFrames: [SKTexture] = [SKTexture]()
    
    override func didMove(to view: SKView) {
        self.close = childNode(withName: "close") as? SKButtonSpriteNode
        self.close?.delegate = self
        
        self.generateExplosion()
        drawGameBodyLimits()
        self.physicsWorld.contactDelegate = self
        
        
        let rectangle = SKShapeNode(rect: CGRect(x: Int(self.frame.midX), y: Int(self.frame.midY) + 300, width: 300, height: 100))
        rectangle.fillColor = .white
        let accionMoverIzquierda = SKAction.move(to: CGPoint(x: Int(self.frame.minX), y: Int(rectangle.position.y)), duration: 2.0)
        let accionMoverDerecha = SKAction.move(to: CGPoint(x: Int(self.frame.maxX), y: Int(rectangle.position.y)), duration: 2.0)
        
        let sequence = SKAction.sequence([accionMoverIzquierda, accionMoverDerecha])
        
        let repeatForever = SKAction.repeatForever(sequence)
        
        rectangle.run(repeatForever, withKey: "repeat")
        
        addChild(rectangle)
    }
}

extension ContactGameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if let nodeA = contact.bodyA.node as? SKCustomComponent,
           let nodeB = contact.bodyB.node as? SKCustomComponent {
            if nodeA.color == nodeB.color {
                nodeA.numberOfContacts = nodeA.numberOfContacts + 1
                nodeB.numberOfContacts = nodeB.numberOfContacts + 1
                if nodeA.numberOfContacts == 10 {
                    explosion(at: contact.contactPoint)
                    removeNodes(nodeA: nodeA, nodeB: nodeB)
                } else if nodeB.numberOfContacts == 10 {
                    explosion(at: contact.contactPoint)
                    removeNodes(nodeA: nodeA, nodeB: nodeB)
                }
            } else {
                nodeB.physicsBody?.applyImpulse(CGVector(dx: 1000.0, dy: 1000.0), at: contact.contactPoint)
                nodeA.physicsBody?.applyForce(CGVector(dx: 1000.0, dy: 1000.0), at: contact.contactPoint)
            }
        }
    }
    private func removeNodes(nodeA: SKNode, nodeB: SKNode) {
        nodeA.removeFromParent()
        nodeB.removeFromParent()
    }
    private func explosion(at location: CGPoint) {
        let firstFrameTexture = explosionFrames[0]
        let explosionNode = SKSpriteNode(texture: firstFrameTexture, size: CGSize(width: 100.0, height: 100.0))
        explosionNode.position = location
        
        
        addChild(explosionNode)
        explosionNode.run(SKAction.animate(with: explosionFrames, timePerFrame: 0.01)) {
            explosionNode.removeAllActions()
            
            explosionNode.removeFromParent()
        }
    }
    
    private func generateExplosion() {
        let explosionAtlas = SKTextureAtlas(named: "explosion")
        var frames: [SKTexture] = [SKTexture]()
        
        let numFrames = explosionAtlas.textureNames.count - 1
        for frame in 0...numFrames {
            let frameName =  "explosion\(frame)"
            frames.append(explosionAtlas.textureNamed(frameName))
        }
        self.explosionFrames = frames
    }
}

extension ContactGameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.numberOfTouches = self.numberOfTouches + 1
        for t in touches {
            let tPosition = t.location(in: self)
            switch self.numberOfTouches % 3 {
            case 0:
                var newShape = createSquare()
                newShape.position = tPosition
                self.physicsBodie(node: &newShape)
                addChild(newShape)
            case 1:
                var newShape = createEllipse()
                newShape.position = tPosition
                self.physicsBodie(node: &newShape)
                addChild(newShape)
            default:
                var newShape = createCircleNode()
                newShape.position = tPosition
                self.physicsBodie(node: &newShape)
                
                addChild(newShape)
            }

        }
    }
    
    private func physicsBodie(node: inout SKCustomComponent) {
        node.physicsBody?.restitution = 1.0
        node.physicsBody?.friction = 0.0
        node.physicsBody?.linearDamping = 0.1
        node.physicsBody?.angularDamping = 0.1
        node.physicsBody?.mass = 10.0
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.pinned = false
        
        node.physicsBody?.categoryBitMask = objectsCategoryBitMask
        node.physicsBody?.collisionBitMask = limitsCategoryBitMask | objectsCategoryBitMask
        node.physicsBody?.contactTestBitMask = objectsCategoryBitMask
    }
    
    private func createSquare() -> SKCustomComponent {
        let newShape = SKCustomComponent(rectOf: CGSize(width: 30, height: 30))
        newShape.fillColor = self.numberOfTouches % 2 == 0 ? .purple : .magenta
        newShape.color = newShape.fillColor
        newShape.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 30))
        
        return newShape
    }
    
    private func createEllipse() -> SKCustomComponent {
        let newShape = SKCustomComponent(ellipseOf: CGSize(width: 45, height: 30))
        newShape.fillColor = self.numberOfTouches % 2 == 0 ? .purple : .green
        newShape.color = newShape.fillColor
        newShape.physicsBody = SKPhysicsBody(circleOfRadius: 30.0)
        
        return newShape
    }
    
    private func createCircleNode() -> SKCustomComponent {
        let newShape = SKCustomComponent(circleOfRadius: 30.0)
        newShape.fillColor = self.numberOfTouches % 2 == 0 ? .purple : .green
        newShape.color = newShape.fillColor
        newShape.physicsBody = SKPhysicsBody(circleOfRadius: 30.0)

        return newShape
    }
}

extension ContactGameScene {
    private func drawGameBodyLimits() {
        let topLeft: CGPoint = CGPoint(x: self.frame.minX, y: self.frame.maxY)
        let topRight: CGPoint = CGPoint(x: self.frame.maxX, y: self.frame.maxY)
        
        let bottomLeft: CGPoint = CGPoint(x: self.frame.minX, y: self.frame.minY)
        let bottomRight: CGPoint = CGPoint(x: self.frame.maxX, y: self.frame.minY)
        
        let bodyPath: CGMutablePath = CGMutablePath()
        bodyPath.addLines(between: [topLeft, topRight, bottomRight, bottomLeft])
        
        let bodie: SKPhysicsBody = SKPhysicsBody(edgeLoopFrom: bodyPath)
        self.physicsBody = bodie
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = limitsCategoryBitMask
    }
}

extension ContactGameScene: SKButtonSpriteNodeDelegate {
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
