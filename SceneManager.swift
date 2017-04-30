//
//  GameManager.swift
//  Project
//
//  Created by Seth Willits on 4/30/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit



class GameManager {
	
	static var shared: GameManager = GameManager()
	var skView: SKView!
	
	
	
	
	
	// MARK: - Game Running
	
	var server: ServerGame? = nil
	var client: ClientGame? = nil
	
	func hostGame(port: Int, playerName: String) {
		precondition(server == nil)
		server = ServerGame()
		
		// Start the server
		do {
			try server!.start(port: port)
		} catch let error {
			server = nil
			NSApp.presentError(error as NSError)
			return
		}
		
		GameManager.shared.showWaitingScene(status: "Connecting...")
		
		// Connect to it as a client
		joinGame(host: "127.0.0.1", port: UInt16(port), playerName: playerName)
		
	}
	
	
	
	func joinGame(host: String, port: UInt16, playerName: String) {
		precondition(client == nil)
		
		// TODO: What about rentry during a connection?? (Test with the wrong port, and it'll take a long time to connect.)
		
		// Maybe not have a shared instance ...
		client = ClientGame()
		
		
		// TODO: in the future, perhaps this join method should have a handler as well.
		// The caller(?) should have the ability to show a "Connecting" screen, or
		// disable the Connect/Join button...
		client!.connect(to: host, port: port, playerName: playerName) { (error: Error?) in
			if let error = error {
				NSBeep()
				print("\(error)")
				self.client = nil
				GameManager.shared.showMainMenu()
			} else {
				GameManager.shared.showLobby()
			}
		}
	}
	
	
	
	
	
	
	
	
	
	
	// MARK: - Scenes
	
	func showMainMenu() {
		let scene = GKScene(fileNamed: "MainMenuScene")!
		let sceneNode = scene.rootNode as! MainMenuScene
		sceneNode.scaleMode = .aspectFill
		skView.presentScene(sceneNode)
	}
	
	
	func showWaitingScene(status: String) {
		let scene = GKScene(fileNamed: "WaitingScene")!
		let sceneNode = scene.rootNode as! WaitingScene
		sceneNode.scaleMode = .aspectFill
		sceneNode.status = status
		skView.presentScene(sceneNode)
	}
	
	
	func showLobby() {
		let scene = GKScene(fileNamed: "LobbyScene")!
		let sceneNode = scene.rootNode as! LobbyScene
		sceneNode.scaleMode = .aspectFill
		skView.presentScene(sceneNode)
	}
}

