//
//  BaseGameScene.swift
//  Project
//
//  Created by Seth Willits on 4/30/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation
import SpriteKit


/// Every scene during the running of a game (lobby, the game, gameover/win etc) derive from this scene.
class BaseGameScene: SKScene {
	
	
	// MARK: - Setup
	
	private var hasLoadedScene = false
	override func sceneDidLoad() {
		// For some reason, this can be called multiple times so guard against it.
		guard hasLoadedScene == false else { return }
		hasLoadedScene = true
		
		
	}
	
	
	
	
	
	// MARK: - Updating
	private var lastUpdateTime : TimeInterval = 0
	
	override func update(_ currentTime: TimeInterval) {
		let clientGame = GameManager.shared.client
		let serverGame = GameManager.shared.server
		
		if clientGame != nil || serverGame != nil {
			if lastUpdateTime == 0 {
				lastUpdateTime = currentTime
			}
			defer { lastUpdateTime = currentTime }
			
			
			// do scene-specific update logic here?
			// just require subclasses to do a super?
			
			
			let timing = ClientGame.UpdateTiming(now: currentTime, delta: currentTime - lastUpdateTime)
			serverGame?.update()
			clientGame?.update(timing: timing)
		}
	}
}

