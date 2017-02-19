//
//  MainMenuScene.swift
//  Project
//
//  Created by Seth Willits on 2/18/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit



class MainMenuScene: SKScene, ButtonNodeResponderType {
	
	
	
	
	func buttonTriggered(button: ButtonNode) {
		switch button.buttonIdentifier! {
		case .newTestGame:
//			SKScene *spaceshipScene  = [[SpaceshipScene alloc] initWithSize:self.size];
//			SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
			let doors = SKTransition.doorsOpenVertical(withDuration: 0.5)
			let gkscene = GKScene(fileNamed: "GameSinglePlayerScene")!
			let scene = gkscene.rootNode as! GameSinglePlayerScene
			view?.presentScene(scene, transition: doors)
			
		case .quit:
			NSApp.terminate(nil)
		}
	}
	
}

