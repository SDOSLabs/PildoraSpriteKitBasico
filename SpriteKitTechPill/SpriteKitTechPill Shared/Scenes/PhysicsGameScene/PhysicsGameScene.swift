//
//  PhysicsGameScene.swift
//  SpriteKitTechPill iOS
//
//  Created by Juan Fuentes on 22/5/23.
//

import SpriteKit

class PhysicsGameScene: SKScene {
    private let limitsCategoryBitMask: UInt32 = 0b00001
    private let objectsCategoryBitMask: UInt32 = 0b0010
    private let bottomResetBarCategoryBitMask: UInt32 = 0b0100
    
    private var numOfHits: Int = 0
    
    
    private var money: SKSpriteNode?
    private var scoreText: SKLabelNode?
    private var close: SKButtonSpriteNode?
    
    override func didMove(to view: SKView) {
        self.money = childNode(withName: "money") as? SKSpriteNode
        self.scoreText = childNode(withName: "score") as? SKLabelNode
        self.close = childNode(withName: "close") as? SKButtonSpriteNode
        self.close?.delegate = self
        
        drawGameBodyLimits()
        self.physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.scoreText?.text = String(numOfHits)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        print("didChangeSize")
        for node in self.children  {
            let newPositionX = node.position.x / oldSize.width * self.frame.size.width
            let newPositionY = node.position.y / oldSize.height * self.frame.size.height
            node.position = CGPoint(x: newPositionX, y: newPositionY)
            
        }
    }
}

extension PhysicsGameScene: SKButtonSpriteNodeDelegate {
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

extension PhysicsGameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA == money?.physicsBody || contact.bodyB == money?.physicsBody {
            numOfHits = 0
        }
    }
}

// MARK: Create
extension PhysicsGameScene {
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
        
        
        // Dibujamos una linea que hara de marcador
        let pathToDraw = CGMutablePath()
        pathToDraw.addLines(between: [
            CGPoint(x: self.frame.minX, y: self.frame.minY + 30),
            CGPoint(x: self.frame.maxX, y: self.frame.minY + 30)
        ]
        )
        
        let bottomResetLine = SKShapeNode()
        bottomResetLine.path = pathToDraw
        bottomResetLine.lineWidth = 2.0
        bottomResetLine.strokeColor = SKColor.white
        
        // Le añadimos el cuerpo fisico
        let lineBody = SKPhysicsBody(edgeChainFrom: pathToDraw)
        bottomResetLine.physicsBody = lineBody
        bottomResetLine.physicsBody?.isDynamic = false
        
        // Le añadimos la mascara de contacto y colision
        bottomResetLine.physicsBody?.categoryBitMask = bottomResetBarCategoryBitMask
        bottomResetLine.physicsBody?.collisionBitMask = objectsCategoryBitMask
        bottomResetLine.physicsBody?.contactTestBitMask = objectsCategoryBitMask
        
        addChild(bottomResetLine)
        
        money?.physicsBody?.categoryBitMask = objectsCategoryBitMask
        money?.physicsBody?.collisionBitMask = bottomResetBarCategoryBitMask | limitsCategoryBitMask
        money?.physicsBody?.contactTestBitMask = bottomResetBarCategoryBitMask
        self.physicsBody?.categoryBitMask = limitsCategoryBitMask
    }
}

// MARK: Tactil Input Methods
extension PhysicsGameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)
            
            if let node = self.physicsWorld.body(at: location) {
                numOfHits = numOfHits + 1
                node.applyImpulse(CGVector(dx: 1000.0, dy: 1000.0), at: location)
            }
        }
    }
}
