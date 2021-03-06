//
//  MainMenuScene.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit



class MainMenuScene: SKScene, ButtonNodeResponderType {
	
	func buttonTriggered(button: ButtonNode) {
		switch button.buttonIdentifier! {
//		case .newTestGame:
//			let doors = SKTransition.doorsOpenVertical(withDuration: 0.5)
//			let gkscene = GKScene(fileNamed: "GameSinglePlayerScene")!
//			let scene = gkscene.rootNode as! GameSinglePlayerScene
//			view!.presentScene(scene, transition: doors)
		
		case .mainMenuHostGame:
			NSApp.sendAction(Selector(("hostGame:")), to: nil, from: nil)
			
		case .mainMenuJoinGame:
			NSApp.sendAction(Selector(("joinGame:")), to: nil, from: nil)
			
		case .quit:
			NSApp.terminate(nil)
		}
	}
	
}

