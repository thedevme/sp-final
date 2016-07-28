//
//  GameScene.swift
//  SoccerDemo
//
//  Created by Craig Clayton on 7/11/16.
//  Copyright (c) 2016 Cocoa Academy. All rights reserved.
//

import SpriteKit
import GameplayKit

enum ColliderType: UInt32
{
    case BallCategory = 1
    case WallCategory = 2
    case Paddle1Category = 4
    case Paddle2Category = 8
    case P1ScoreCategory = 16
    case P2ScoreCategory = 32
}

enum Player {
    case Player1
    case Player2
}

enum NumberOfPlayers:Int {
    case OnePlayer = 1
    case TwoPlayers = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var cursor:SKSpriteNode?
    var btn1Player:SKSpriteNode?
    var btn2Player:SKSpriteNode?
    var player1:SKSpriteNode?
    var player2:SKSpriteNode?
    var lblNodeP1Score:SKLabelNode!
    var lblNodeP2Score:SKLabelNode!
    var ballNode:SKSpriteNode!
    var goalTextNode:SKSpriteNode!
    var topWallNode:SKSpriteNode!
    var background:SKNode!
    
    var player1Score = 0
    var player2Score = 0
    var winScore = 10
    
    var upValue:CGFloat = 0
    var downValue:CGFloat = 0
    let playerSize = CGSizeMake(100, 200)
    
    let multiplier:Float = 10.0
    
    var btn1PlayerLoc = CGPointZero
    var btn2PlayerLoc = CGPointZero
    
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    
    let tapSelectedRec = UITapGestureRecognizer()
    let tapPlayPauseRec = UITapGestureRecognizer()
    
    var numOfPlayers = NumberOfPlayers.OnePlayer
    
    let velocity = 1.18 as CGFloat
    let english = CGFloat(arc4random_uniform(50))
    
    var timer: NSTimer!
    
    let blockBallAudio = SKAudioNode(fileNamed: "paddle_hit.wav")
    let wallAudio = SKAudioNode(fileNamed: "wall_hit.wav")
    let goalAudio = SKAudioNode(fileNamed: "goal_short.wav")
    let soccerFrame = CGRectMake(150, 200, 1550, 680)
    let font = "SuperMarioGalaxy"
    
    lazy var gameState: GKStateMachine = GKStateMachine(states: [
            MenuState(scene: self),
            PlayingState(scene: self),
            PausedState(scene: self)
    ])
    
    override func didMoveToView(view: SKView) {
        createMenu()
        addSwipeGestureRecognizers()
        addTapGestureRecognizers()
        setupPhysics()
        createGoalText()
        createPlayers()
        createGoals()
        createCorners()
        createScore()
        
        
        
        gameState.enterState(MenuState)
    }
   
    override func update(currentTime: CFTimeInterval) {
        if gameState.currentState is PlayingState {
            updateBallRotation()
            updatePaddlePositions()
        }
    }
    
    func updateBallRotation() {
        var angle = cos((ballNode.physicsBody?.velocity.dx)!)
        angle += sin((ballNode.physicsBody?.velocity.dy)!)
        ballNode.zRotation = angle
    }
    
    func createMenu() {
        cursor = childNodeWithName("//cursor") as? SKSpriteNode
        btn1Player = childNodeWithName("//btn1Player") as? SKSpriteNode
        btn2Player = childNodeWithName("//btn2Players") as? SKSpriteNode
        background = childNodeWithName("//background")
        
        goalAudio.autoplayLooped = false
        blockBallAudio.autoplayLooped = false
        wallAudio.autoplayLooped = false
        
        background!.addChild(blockBallAudio)
        background!.addChild(goalAudio)
        background!.addChild(wallAudio)
        
        btn1PlayerLoc = CGPointMake(btn1Player!.position.x, btn1Player!.position.y)
        btn2PlayerLoc = CGPointMake(btn2Player!.position.x, btn2Player!.position.y)
    }
    
    func setupPhysics()
    {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVectorMake(0, 0)
        
        physicsBody = SKPhysicsBody.init(edgeLoopFromRect: soccerFrame)
        physicsBody!.contactTestBitMask = ColliderType.WallCategory.rawValue
        
        physicsBody!.dynamic = false
        physicsBody!.friction = 0.0
        physicsBody!.restitution = 1.0
    }
    
    func createGoals() {
        let leftRect = CGRectMake(150, 300, 60, 480)
        let left = SKNode()
        left.physicsBody = SKPhysicsBody(edgeLoopFromRect: leftRect)
        left.physicsBody?.categoryBitMask = ColliderType.P1ScoreCategory.rawValue
        
        self.addChild(left)
        
        let rightRect = CGRectMake(1660, 300, 40, 480)
        let right = SKNode()
        right.physicsBody = SKPhysicsBody(edgeLoopFromRect: rightRect)
        right.physicsBody?.categoryBitMask = ColliderType.P2ScoreCategory.rawValue
        
        self.addChild(right)
    }
    
    func createCorners() {
        let topLeftCornerRect = CGRectMake(150, 780, 115, 100)
        let topLeftCorner = SKNode()
        topLeftCorner.physicsBody = SKPhysicsBody(edgeLoopFromRect: topLeftCornerRect)
        topLeftCorner.physicsBody!.contactTestBitMask = ColliderType.WallCategory.rawValue
        self.addChild(topLeftCorner)
        
        let bottomLeftCornerRect = CGRectMake(150, 200, 115, 100)
        let bottomLeftCorner = SKNode()
        bottomLeftCorner.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomLeftCornerRect)
        bottomLeftCorner.physicsBody!.contactTestBitMask = ColliderType.WallCategory.rawValue
        self.addChild(bottomLeftCorner)
        
        let topRightCornerRect = CGRectMake(1600, 780, 100, 100)
        let topRightCorner = SKNode()
        topRightCorner.physicsBody = SKPhysicsBody(edgeLoopFromRect: topRightCornerRect)
        topRightCorner.physicsBody!.contactTestBitMask = ColliderType.WallCategory.rawValue
        self.addChild(topRightCorner)
        
        let bottomRightCornerRect = CGRectMake(1600, 200, 100, 100)
        let bottomRightCorner = SKNode()
        bottomRightCorner.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRightCornerRect)
        bottomRightCorner.physicsBody!.contactTestBitMask = ColliderType.WallCategory.rawValue
        self.addChild(bottomRightCorner)
    }
    
    func createPlayers()
    {
        createPlayer1()
        createPlayer2()
    }
    
    func createPlayer1()
    {
        let player1Texture = SKTextureAtlas(named:"p1")
        
        player1 = SKSpriteNode(texture: player1Texture.textureNamed("p1_hit0"), size: playerSize )
        player1!.position = CGPointMake(409, 537)
        player1!.physicsBody = SKPhysicsBody.init(rectangleOfSize: player1!.size)
        player1!.physicsBody!.categoryBitMask = ColliderType.Paddle1Category.rawValue
        player1!.physicsBody!.dynamic = false
        player1!.alpha = 0
        addChild(player1!)
    }
    
    func createPlayer2()
    {
        let player2Texture = SKTextureAtlas(named:"p2")
        
        player2 = SKSpriteNode(texture: player2Texture.textureNamed("p2_hit0"), size: playerSize )
        player2!.position = CGPointMake(1450, 537)
        player2!.physicsBody = SKPhysicsBody.init(rectangleOfSize: player2!.size)
        player2!.physicsBody!.categoryBitMask = ColliderType.Paddle2Category.rawValue
        player2!.physicsBody!.dynamic = false
        player2!.alpha = 0
        addChild(player2!)
    }
    
    func createScore()
    {
        createPlayer1Score(font)
        createPlayer2Score(font)
    }
    
    func createPlayer1Score(font:String)
    {
        lblNodeP1Score = SKLabelNode(fontNamed: font)
        lblNodeP1Score.position = CGPointMake(128, 510)
        lblNodeP1Score?.fontColor = .blackColor()
        lblNodeP1Score?.text = "0"
        lblNodeP1Score?.physicsBody?.dynamic = false
        lblNodeP1Score?.fontSize = CGFloat(90)
        lblNodeP1Score?.zPosition = 99
        addChild(lblNodeP1Score)
    }
    
    func createPlayer2Score(font:String)
    {
        lblNodeP2Score = SKLabelNode(fontNamed: font)
        lblNodeP2Score.position = CGPointMake(1728, 510)
        lblNodeP2Score?.fontColor = .blackColor()
        lblNodeP2Score?.text = "0"
        lblNodeP2Score?.physicsBody?.dynamic = false
        lblNodeP2Score?.fontSize = CGFloat(90)
        lblNodeP2Score?.zPosition = 99
        addChild(lblNodeP2Score)
    }
    
    func addSwipeGestureRecognizers() {
        swipeUpRec.addTarget(self, action: #selector(GameScene.onMenuSwipe(_:)))
        swipeUpRec.direction = .Up
        view!.addGestureRecognizer(swipeUpRec)
        
        swipeDownRec.addTarget(self, action: #selector(GameScene.onMenuSwipe(_:)))
        swipeDownRec.direction = .Down
        view!.addGestureRecognizer(swipeDownRec)
    }
    
    func removeSwipeGestureRecognizers() {
        swipeUpRec.addTarget(self, action: #selector(GameScene.onMenuSwipe(_:)))
        swipeUpRec.direction = .Up
        view!.removeGestureRecognizer(swipeUpRec)
        
        swipeDownRec.addTarget(self, action: #selector(GameScene.onMenuSwipe(_:)))
        swipeDownRec.direction = .Down
        view!.removeGestureRecognizer(swipeDownRec)
    }
    
    func addTapGestureRecognizers() {
        

        tapPlayPauseRec.addTarget(self, action: #selector(GameScene.onPlayPauseTapped))
        tapPlayPauseRec.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)]
        view!.addGestureRecognizer(tapPlayPauseRec)
    }
    
    func addMenuTapGestureRecognizers() {
        tapSelectedRec.addTarget(self, action: #selector(GameScene.onSelectedTapped))
        tapSelectedRec.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
        view!.addGestureRecognizer(tapSelectedRec)
    }
    
    
    func removeMenuTapGestureRecognizers() {
        tapSelectedRec.addTarget(self, action: #selector(GameScene.onSelectedTapped))
        tapSelectedRec.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
        view!.removeGestureRecognizer(tapSelectedRec)
    }
    
    func createGoalText()
    {
        goalTextNode = SKSpriteNode(imageNamed: "goal")
        goalTextNode.size = CGSizeMake(660, 240)
        goalTextNode.position = CGPointMake(940, 750)
        goalTextNode.zPosition = 999
        goalTextNode.hidden = true
        
        addChild(goalTextNode)
    }
    
    func showGoalText()
    {
        goalTextNode.hidden = false
        performSelector(#selector(GameScene.hideGoalText), withObject: self, afterDelay: 4)
    }
    
    func hideGoalText()
    {
        goalTextNode.hidden = true
    }
    
    func serveBall()
    {
        checkBall()
        
        let ballRadius:CGFloat = 22
        let ballTexture = SKTextureAtlas(named: "ball")
        
        createBallPhysics(ballTexture, radius: ballRadius)
        createBallAnimation(ballTexture)
        
        addChild(ballNode)
        
        createBallVelocity()
    }
    
    func createBallPhysics(texture:SKTextureAtlas, radius:CGFloat)
    {
        ballNode = SKSpriteNode(texture: texture.textureNamed("ball0"), size: CGSizeMake(128, 128))
        ballNode!.physicsBody = SKPhysicsBody.init(circleOfRadius: radius)
        ballNode!.physicsBody!.categoryBitMask = ColliderType.BallCategory.rawValue
        ballNode!.physicsBody!.contactTestBitMask = ColliderType.P1ScoreCategory.rawValue | ColliderType.P2ScoreCategory.rawValue | ColliderType.BallCategory.rawValue | ColliderType.Paddle1Category.rawValue | ColliderType.Paddle2Category.rawValue | ColliderType.WallCategory.rawValue
        ballNode!.physicsBody!.linearDamping = 0.0
        ballNode!.physicsBody!.angularDamping = 0.0
        ballNode!.physicsBody!.restitution = 1.0
        ballNode!.physicsBody!.dynamic = true
        ballNode!.physicsBody!.friction = 0.0
        ballNode!.physicsBody!.allowsRotation = true
        ballNode.position = CGPointMake(932, 540)
    }
    
    func checkBall()
    {
        if ballNode != nil
        {
            ballNode.removeFromParent()
        }
    }
    
    func createBallAnimation(ballTexture:SKTextureAtlas)
    {
        var animFrames = [SKTexture]()
        let numImages = ballTexture.textureNames.count
        
        for i in 0 ..< numImages {
            let ballTextureName = "ball\(i)"
            animFrames.append(ballTexture.textureNamed(ballTextureName))
        }
        
        if ballNode != nil {
            ballNode.runAction(SKAction.repeatActionForever(
                SKAction.animateWithTextures(animFrames,
                    timePerFrame: 0.03,
                    resize: false,
                    restore: true)), withKey:"ballAnimation")
        }
        else {
            let ballRadius:CGFloat = 22
            let ballTexture = SKTextureAtlas(named: "ball")
            
            createBallPhysics(ballTexture, radius: ballRadius)
            ballNode.runAction(SKAction.repeatActionForever(
                SKAction.animateWithTextures(animFrames,
                    timePerFrame: 0.03,
                    resize: false,
                    restore: true)), withKey:"ballAnimation")
        }
    }
    
    func createHitAnimation(type:String, playerTexture:SKTextureAtlas)
    {
        var animFrames = [SKTexture]()
        let numImages = playerTexture.textureNames.count
        var playerType = ""
        
        for i in 0 ..< numImages {
            if type == "p1" { playerType = "p1" }
            else { playerType = "p2" }
            let hitTextureName = "\(playerType)_hit\(i)"
            animFrames.append(playerTexture.textureNamed(hitTextureName))
        }
        
        if type == "p1" {
            player1!.runAction(
                SKAction.animateWithTextures(animFrames,
                    timePerFrame: 0.01,
                    resize: false,
                    restore: true), withKey:"player1HitAnimation")
            
        }
        else {
            player2!.runAction(
                SKAction.animateWithTextures(animFrames,
                    timePerFrame: 0.01,
                    resize: false,
                    restore: true), withKey:"player2HitAnimation")
        }
    }
    
    func createBallVelocity()
    {
        let velocity = CGFloat(soccerFrame.size.width/70) * CGFloat(20)
        let english = arc4random_uniform(UInt32(velocity * 2))
        var startingVelocityX: CGFloat = velocity
        let startingVelocityY: CGFloat = velocity - CGFloat(english)
        
        if player1Score < player2Score {
            startingVelocityX = -startingVelocityX
        }
        
        ballNode.physicsBody!.velocity = CGVectorMake(startingVelocityX, startingVelocityY)
    }
    
    func scorePointForPlayer(player:Int)
    {
        showGoalText()
        stopBall()
        
        switch player {
        case 1 :
            player2Score = player2Score + 1
        case 2:
            player1Score = player1Score + 1
        default:
            break
        }
        
        updateScore()
        checkScore()
    }
    
    
    func didBeginContact(contact: SKPhysicsContact)
    {
        if gameState.currentState is PlayingState {
            var firstBody = SKPhysicsBody()
            var secondBody = SKPhysicsBody()
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
                
            }else{
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if firstBody.contactTestBitMask == ColliderType.BallCategory.rawValue || secondBody.contactTestBitMask == ColliderType.WallCategory.rawValue {
                background!.runAction(
                    SKAction.sequence([
                        SKAction.runBlock {
                            self.wallAudio.runAction(SKAction.play())
                        }]
                    ))
            }

            
            if firstBody.categoryBitMask == ColliderType.BallCategory.rawValue && secondBody.categoryBitMask == ColliderType.P1ScoreCategory.rawValue {
                scorePointForPlayer(2)
                
                background!.runAction(
                    SKAction.sequence([
                        SKAction.runBlock {
                            self.goalAudio.runAction(SKAction.play())
                        }]
                    ))
            }
            
            if firstBody.categoryBitMask == ColliderType.BallCategory.rawValue && secondBody.categoryBitMask == ColliderType.P2ScoreCategory.rawValue {
                scorePointForPlayer(1)
                
                background!.runAction(
                    SKAction.sequence([
                        SKAction.runBlock {
                            self.goalAudio.runAction(SKAction.play())
                        }]
                    ))
            }
            
            if firstBody.categoryBitMask == ColliderType.BallCategory.rawValue && secondBody.categoryBitMask == ColliderType.Paddle1Category.rawValue {
                let p1Texture = SKTextureAtlas(named: "p1")
                createHitAnimation("p1", playerTexture: p1Texture)
                createHitSound(.Player1)
            }
            
            if firstBody.categoryBitMask == ColliderType.BallCategory.rawValue && secondBody.categoryBitMask == ColliderType.Paddle2Category.rawValue {
                let p2Texture = SKTextureAtlas(named: "p2")
                createHitAnimation("p2", playerTexture: p2Texture)
                createHitSound(.Player2)
            }
        }
    }
    
    func createHitSound(player:Player) {
        if player == .Player1 {
            player1!.runAction(
                SKAction.sequence([
                    SKAction.runBlock {
                        self.blockBallAudio.runAction(SKAction.play())
                    }]
                ))
        }
        else {
            player2!.runAction(
                SKAction.sequence([
                    SKAction.runBlock {
                        self.blockBallAudio.runAction(SKAction.play())
                    }]
                ))
        }
    }
    
    func stopBall()
    {
        ballNode.physicsBody!.velocity = CGVectorMake(0, 0)
        ballNode.removeFromParent()
    }
    
    func updateScore()
    {
        lblNodeP1Score.text = "\(player1Score)"
        lblNodeP2Score.text = "\(player2Score)"
    }
    
    func checkScore()
    {
        if player1Score == winScore || player2Score == winScore {
            // game over
        }
        else
        {
            performSelector(#selector(GameScene.serve), withObject: self, afterDelay: 4)
        }
    }
    
    func serve()
    {
        addChild(ballNode)
        
        invalidateTimer()
        serveBall()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5.8, target: self, selector: #selector(GameScene.accelerateBall), userInfo: nil, repeats: true)
    }
    
    func updatePaddlePositions()
    {
        for i in 0..<GameViewController.controllers.count {
            let gameViewController = GameViewController()
            let direction = gameViewController.controllerDirection(controllerIndex: i)
            
            if direction.y > 0.0002 || direction.y < -0.0002 {
                let paddleNode = (i == 0) ? player1 : player2
                movePaddle(paddleNode!, y: direction.y)
            }
        }
    }
    
    func movePaddle(paddle:SKSpriteNode, y:Float)
    {
        let reverseDirection = y
        
        var vector = CGFloat(reverseDirection * 5)
        vector = CGFloat(reverseDirection * 15)
        
        var calculatedY = paddle.position.y + (vector * -1)
        let max = 802 as CGFloat
        let min = 280 as CGFloat
        
        if (calculatedY > max) { calculatedY = max }
        if (calculatedY < min) { calculatedY = min }
        
        let yPosition = CGFloat(calculatedY)
        
        paddle.position = CGPointMake(paddle.position.x, yPosition)
    }

    func invalidateTimer()
    {
        if timer != nil
        {
            timer.invalidate()
        }
        
        timer = nil
    }
    
    func accelerateBall()
    {
        if view?.paused == true {
            return
        }
        
        let velocityX: CGFloat = ballNode.physicsBody!.velocity.dx * velocity
        let velocityY: CGFloat = ballNode.physicsBody!.velocity.dy * velocity  + english
        ballNode.physicsBody!.velocity = CGVectorMake(velocityX, velocityY)
    }
    
    func onMenuSwipe(data:UISwipeGestureRecognizer) {
        switch data.direction {
            case UISwipeGestureRecognizerDirection.Down:
                let actMove = SKAction.moveToY(btn2PlayerLoc.y, duration: 0.3)
                actMove.timingMode = .EaseOut
                cursor?.runAction(actMove)
                numOfPlayers = .TwoPlayers
                break
            
            case UISwipeGestureRecognizerDirection.Up:
                let actMove = SKAction.moveToY(btn1PlayerLoc.y, duration: 0.3)
                actMove.timingMode = .EaseOut
                cursor?.runAction(actMove)
                numOfPlayers = .OnePlayer
                break
            
            default:
                break
        }
    }
    
    func onSelectedTapped() {
        print("play game with \(numOfPlayers.rawValue) number of players")
        
        if gameState.currentState is MenuState {
            gameState.enterState(PlayingState)
        }
        else if gameState.currentState is PlayingState {
            gameState.enterState(PausedState)
            print("pause game")
        }
        else if gameState.currentState is PausedState {
            gameState.enterState(PlayingState)
        }
        else {
            print("this state hasnt been setup \(gameState.currentState)")
        }
    }
    
    func onPlayPauseTapped() {
        print("play game with \(numOfPlayers.rawValue) number of players")
        
        if gameState.currentState is MenuState {
            gameState.enterState(PlayingState)
        }
        else if gameState.currentState is PlayingState {
            gameState.enterState(PausedState)
            print("pause game")
        }
        else if gameState.currentState is PausedState {
            
            gameState.enterState(PlayingState)
        }
        else {
            print("this state hasnt been setup \(gameState.currentState)")
        }
    }
}
