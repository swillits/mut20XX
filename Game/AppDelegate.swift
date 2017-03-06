//
//  AppDelegate.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//


import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var window: NSWindow!
	var sceneViewController = SceneViewController()
	var hostGameViewController = HostGameViewController()
	var joinGameViewController = JoinGameViewController()
	
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Prefs.registerDefaults(Prefs.gameDefaults)
		window.contentView!.addSubview(sceneViewController.view)
		sceneViewController.showMainMenu()
	}
	
	
	
	@IBAction func hostGame(_ sender: AnyObject?) {
		let hgvc = hostGameViewController
		let dialog = Dialog(contentViewController: hgvc)
		if dialog.runModal() == NSModalResponseOK {
			let port = hgvc.serverPortField.integerValue
			let playerName = hgvc.playerNameField.stringValue
			
			// Start the server
			do {
				try Server.shared.start(port: port)
			} catch let error {
				NSApp.presentError(error as NSError)
			}
			
			// Connect to it as a client
			joinGame(host: "127.0.0.1", port: UInt16(port), playerName: playerName) 
		}
	}
	
	
	@IBAction func joinGame(_ sender: AnyObject?) {
		
	}
	
	
	
	func joinGame(host: String, port: UInt16, playerName: String) {
		// TODO: What about rentry during a connection?? (Test with the wrong port, and it'll take a long time to connect.)
		
		// Maybe not have a shared instance ...
		Game.shared.newGame()
		
		
		// TODO: in the future, perhaps this join method should have a handler as well.
		// The caller(?) should have the ability to show a "Connecting" screen, or
		// disable the Connect/Join button...
		Game.shared.connect(to: host, port: port, playerName: playerName) { (error: Error?) in
			if let error = error {
				NSBeep()
				print("\(error)")
				
				//Game.shared.reset() / = nil ?
				
			} else {
				
				// TODO: transition to lobby scene
			}
		}
	}
}
