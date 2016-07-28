//
//  MenuState.swift
//  SoccerDemo
//
//  Created by Craig Clayton on 7/13/16.
//  Copyright © 2016 Cocoa Academy. All rights reserved.
//

import SpriteKit
import GameplayKit

class MenuState: GKState {
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        print("menu state did enter")
        
        scene.addSwipeGestureRecognizers()
        scene.addMenuTapGestureRecognizers()
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is PlayingState.Type
    }
    
    override func willExitWithNextState(nextState: GKState) {
        
        let fade = SKAction.fadeAlphaTo(0, duration: 0.3)
        scene.childNodeWithName("//menuLogo")!.runAction(fade)
        scene.childNodeWithName("//cursor")!.runAction(fade)
        scene.childNodeWithName("//btn1Player")!.runAction(fade)
        scene.childNodeWithName("//btn2Players")!.runAction(fade)
    }
}
