//
//  GameViewController.swift
//  SoccerDemo
//
//  Created by Craig Clayton on 7/11/16.
//  Copyright (c) 2016 Cocoa Academy. All rights reserved.
//

import UIKit
import SpriteKit
import GameController

class GameViewController: UIViewController {
    
    static let maxControllers = 2
    
    static let controllerAcceleration = Float(1.0)
    private static let controllerDirectionLimit = float2(1.0)
    
    var controllerDPad: GCControllerDirectionPad?
    var controllerStoredDirection = float2(0.0)
    
    var scene:GameScene!
    static var controllers = [GCController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let gameScene = GameScene(fileNamed: "GameScene") {
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = false
            gameScene.scaleMode = .ResizeFill
            skView.showsPhysics = false
            scene = gameScene
            
            skView.presentScene(gameScene)
            setupGameControllers()
        }
    }
    
    func controllerDirection(controllerIndex index: Int) -> float2 {
        var dpad: GCControllerDirectionPad! = nil
        if GameViewController.controllers[index].extendedGamepad != nil {
            // extended gamepad
            if GameViewController.controllers[index].extendedGamepad!.dpad.xAxis.value != 0.0 || GameViewController.controllers[index].extendedGamepad!.dpad.yAxis.value != 0.0 {
                dpad = GameViewController.controllers[index].extendedGamepad!.dpad
            }
            else {
                // left thumbstick
                dpad = GameViewController.controllers[index].extendedGamepad!.leftThumbstick
            }
        }
        else if GameViewController.controllers[index].microGamepad != nil {
            dpad = GameViewController.controllers[index].microGamepad!.dpad
        }
        
        if let dpad = dpad {
            if dpad.xAxis.value == 0.0 && dpad.yAxis.value == 0.0 {
                controllerStoredDirection = float2(0.0)
            } else {
                controllerStoredDirection = float2(dpad.xAxis.value, -dpad.yAxis.value) *  GameViewController.controllerAcceleration
            }
        }
        
        return controllerStoredDirection
    }
    
    func setupGameControllers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.handleControllerDidConnectNotification(_:)), name: GCControllerDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.handleControllerDidDisconnectNotification(_:)), name: GCControllerDidDisconnectNotification, object: nil)
    }
    
    @objc func handleControllerDidDisconnectNotification(notification: NSNotification) {
        let gameController = notification.object as! GCController
        let index = GameViewController.controllers.indexOf(gameController)
        if let index = index {
            GameViewController.controllers.removeAtIndex(index)
        }
    }
    
    @objc func handleControllerDidConnectNotification(notification: NSNotification) {
        let gameController = notification.object as! GCController
        registerControllerMovementEvents(gameController)
    }
    
    private func registerControllerMovementEvents(gameController: GCController) {
        
        if GameViewController.controllers.count >= GameViewController.maxControllers {
            return
        }
        
        if GameViewController.controllers.contains(gameController) {
            return
        }
        
        GameViewController.controllers.append(gameController)
        
        let movementHandler: GCControllerDirectionPadValueChangedHandler = { [unowned self] dpad, _, _ in
            self.controllerDPad = dpad
        }
        
        #if os(tvOS)
            // Apple TV remote
            if let microGamepad = gameController.microGamepad {
                microGamepad.allowsRotation = true
                microGamepad.dpad.valueChangedHandler = movementHandler
                microGamepad.buttonA.valueChangedHandler = {(button: GCControllerButtonInput, value: Float, pressed: Bool) in
                }
            }
        #endif
        
        // Gamepad D-pad
        if let gamepad = gameController.gamepad {
            gamepad.dpad.valueChangedHandler = movementHandler
        }
        
        // Extended gamepad left and right thumbstick
        if let extendedGamepad = gameController.extendedGamepad {
            extendedGamepad.leftThumbstick.valueChangedHandler = movementHandler
            extendedGamepad.rightThumbstick.valueChangedHandler = movementHandler
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
