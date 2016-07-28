//
//  GameState.swift
//  SoccerDemo
//
//  Created by Craig Clayton on 7/13/16.
//  Copyright © 2016 Cocoa Academy. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlayingState: GKState {
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        print("playing state did enter")
        if previousState is MenuState {
            scene.removeSwipeGestureRecognizers()
            scene.removeMenuTapGestureRecognizers()
            
            let fade = SKAction.fadeAlphaTo(1.0, duration: 0.5)
            scene.player1!.runAction(fade)
            scene.player2!.runAction(fade)
            let ballTexture = SKTextureAtlas(named: "ball")
            scene.createBallAnimation(ballTexture)
            scene.serveBall()
            scene.ballNode.hidden = false
        }
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is PausedState.Type || stateClass is MenuState.Type
    }
    
    override func willExitWithNextState(nextState: GKState) {
        print("playing state will exit")
//        let scale = SKAction.scaleTo(0, duration: 0.4)
//        scene.childNodeWithName("//menuLogo")!.runAction(scale)
    }
}
