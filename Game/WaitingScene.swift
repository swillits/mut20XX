//
//  WaitingScene.swift
//  Project
//
//  Created by Seth Willits on 4/30/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation
import SpriteKit


/// A scene for when waiting on something. The status should be something like "connecting" or "loading"  
class WaitingScene: BaseGameScene {
	
	
	var status: String = "Waiting…" {
		didSet {
			if let labelNode = childNode(withName: "label") as? SKLabelNode {
				labelNode.text = status
			}
		}
	}
	
	
}
