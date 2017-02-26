//
//  SceneViewController.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class SceneViewController: NSViewController {

    @IBOutlet var skView: SKView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        skView.showsFPS = true
		skView.showsNodeCount = true
    }
	
	
	func showMainMenu() {
		let scene = GKScene(fileNamed: "MainMenuScene")!
		let sceneNode = scene.rootNode as! MainMenuScene
		sceneNode.scaleMode = .aspectFill
		skView.presentScene(sceneNode)
	}
}

