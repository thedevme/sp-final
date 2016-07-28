//
//  PausedState.swift
//  SoccerDemo
//
//  Created by Craig Clayton on 7/13/16.
//  Copyright © 2016 Cocoa Academy. All rights reserved.
//

import SpriteKit
import GameplayKit

class PausedState: GKState {
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        print("paused state did enter")

        if !scene.didPlayerScore {
            scene.ballNode!.physicsBody!.dynamic = false
            //        scene.stopBallAnimation()
            scene.ballNode!.hidden = true
        }
        else {
            scene.hideGoalText()
            scene.invalidateTimer()
            scene.background!.runAction(
                SKAction.runBlock {
                    self.scene.goalAudio.runAction(SKAction.stop())
                })
            
        }
        
        scene.childNodeWithName("//pausedContainer")?.alpha = 1.0
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is PlayingState.Type || stateClass is MenuState.Type
    }
    
    override func willExitWithNextState(nextState: GKState) {
        print("paused state will exit")
        scene.ballNode!.hidden = false
        scene.ballNode!.physicsBody!.dynamic = true
        
        scene.childNodeWithName("//pausedContainer")?.alpha = 0.0
        scene.serveBall()
    }
}
