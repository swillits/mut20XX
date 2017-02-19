//
//  GameSinglePlayerScene.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import SpriteKit
import GameplayKit



class GameSinglePlayerScene: SKScene {
	
	
	
	
	override func sceneDidLoad() {
		
		lastUpdateTime = 0
		
		
		let node = PieceBlockNode(variety: .b)
		node.position = CGPoint(x: 100, y: 100)
		childNode(withName: "background")!.addChild(node)
	}
	
	
	
	
	
	
	
	
	
	
	// MARK: - Events
	
	override func keyDown(with event: NSEvent) {
//		switch event.keyCode {
//		default:
//			print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
//		}
	}
	
	
	
	
	
	
	
	
	
	// MARK: - Updating
	private var lastUpdateTime : TimeInterval = 0
	
	override func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
		
		// Initialize _lastUpdateTime if it has not already been
		if lastUpdateTime == 0 {
			lastUpdateTime = currentTime
		}
		
		// Calculate time since last update
//		let dt = currentTime - lastUpdateTime
		
		// Update entities
//		for entity in entities {
//			entity.update(deltaTime: dt)
//		}
		
		lastUpdateTime = currentTime
	}
}
