////
////  GameSceneExtension.swift
////  SoccerPongWkspFinal
////
////  Created by Craig Clayton on 6/26/16.
////  Copyright © 2016 Cocoa Academy. All rights reserved.
////
//
//import Foundation
//import SpriteKit
//import GameController
//
////enum ControllerType {
////    case .Standard
////    case .Extended
////    case .Micro
////}
//
//extension GameScene {
//    
//    
//    func addObservers() {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.connectControllers), name: GCControllerDidConnectNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.disconnectControllers), name: GCControllerDidDisconnectNotification, object: nil)
//    }
//    
//    func connectControllers() {
//        
//        for controller in GCController.controllers()
//        {
//            if (controller.extendedGamepad != nil &&
//                controller.playerIndex == .IndexUnset) {
//                controller.playerIndex = .Index1
//                controller.extendedGamepad?.valueChangedHandler = nil
//                setupExtendedController(controller)
//            }
//            else if (controller.gamepad != nil &&
//                controller.playerIndex == .IndexUnset) {
//                controller.playerIndex = .Index1
//                controller.extendedGamepad?.valueChangedHandler = nil
//                setupStandardController(controller)
//            }
//        }
//        
//        for controller in GCController.controllers()
//        {
//            if (controller.extendedGamepad != nil &&
//                controller.playerIndex == .IndexUnset) {
//                // ignore
//                
//            }
//            else if (controller.gamepad != nil &&
//                controller.playerIndex == .IndexUnset) {
//                // ignore
//                
//            }
//            else if (controller.microGamepad != nil &&
//                controller.playerIndex == .IndexUnset) {
//                controller.playerIndex = .Index1 // For testing leave as Index1 - controller.playerIndex = .Index2
//                setupMicroController(controller)
//                
//            }
//        }
//    }
//    
//    func disconnectControllers() {
//        
//    }
//    
//    func setupStandardController(controller: GCController)
//    {
//        controller.gamepad?.valueChangedHandler = { [weak self] (gamepad: GCGamepad, element: GCControllerElement) in
//            if let weakSelf = self {
//                if gamepad.dpad == element
//                {
//                    if gamepad.dpad.down.pressed == true
//                    {
//                        weakSelf.reset()
//                        weakSelf.moveDown(1)
//                    }
//                    else if gamepad.dpad.up.pressed == true
//                    {
//                        weakSelf.reset()
//                        weakSelf.moveUp(1)
//                    }
//                }
//            }
//        }
//    }
//    
//    func setupExtendedController(controller: GCController)
//    {
//        
//        controller.extendedGamepad?.valueChangedHandler = {  (gamepad: GCExtendedGamepad, element: GCControllerElement) in
//            //
//            
//            if gamepad.leftThumbstick == element
//            {
//                if gamepad.leftThumbstick.down.value > 0.2
//                {
//                    self.reset()
//                    self.moveDown(gamepad.leftThumbstick.down.value * self.multiplier)
//                }
//                else if gamepad.leftThumbstick.up.value > 0.2
//                {
//                    self.reset()
//                    self.moveUp(gamepad.leftThumbstick.up.value * self.multiplier)
//                }
//                else {
//                    self.reset()
//                }
//            }
//            else if gamepad.dpad == element
//            {
//                if gamepad.dpad.down.pressed == true
//                {
//                    self.reset()
//                    self.moveDown(1 * self.multiplier)
//                }
//                else if gamepad.dpad.up.pressed == true
//                {
//                    self.reset()
//                    self.moveUp(1 * self.multiplier)
//                }
//                else {
//                    self.reset()
//                }
//            }
//        }
//    }
//    
//    func setupMicroController(controller:GCController)
//    {
//        controller.microGamepad?.valueChangedHandler = { [weak self] (gamepad: GCMicroGamepad, element: GCControllerElement) in
//            gamepad.reportsAbsoluteDpadValues = true
//            gamepad.allowsRotation = true
//            
//            if let weakSelf = self {
//                if gamepad.dpad == element
//                {
//                    if gamepad.dpad.down.value > 0.2
//                    {
//                        weakSelf.reset()
//                        weakSelf.moveDown(gamepad.dpad.down.value)
//                    }
//                    else if gamepad.dpad.up.value > 0.2
//                    {
//                        weakSelf.reset()
//                        weakSelf.moveUp(gamepad.dpad.up.value)
//                    }
//                    else {
//                        weakSelf.reset()
//                    }
//                }
//            }
//        }
//    }
//    
//    func moveUp(speed:Float) {
//        upValue = CGFloat(speed)
//    }
//    
//    func moveDown(speed:Float) {
//        downValue = -CGFloat(speed)
//    }
//    
//    func reset() {
//        downValue = 0
//        upValue = 0
//    }
//}