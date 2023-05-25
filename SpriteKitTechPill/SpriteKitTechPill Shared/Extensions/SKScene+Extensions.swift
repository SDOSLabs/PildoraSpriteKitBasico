//
//  SKScene+Extensions.swift
//  SpriteKitTechPill iOS
//
//  Created by Juan Fuentes on 19/5/23.
//

import SpriteKit

public extension SKScene {
    func resizeWithFixedHeightTo(viewportSize: CGSize) {
        self.scaleMode = .aspectFill
        
        let aspectRatio = viewportSize.width / viewportSize.height
        
        self.size = CGSize(width: self.size.height * aspectRatio, height: self.size.height)
    }
}
