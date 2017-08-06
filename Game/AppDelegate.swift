//
//  AppDelegate.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//


import Cocoa
import SpriteKit


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var window: NSWindow!
	@IBOutlet var skView: SKView!
	
	var hostGameViewController = HostGameViewController()
	var joinGameViewController = JoinGameViewController()
	
	
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Prefs.registerDefaults(Prefs.gameDefaults)
		skView.showsFPS = true
		skView.showsNodeCount = true
		
		GameManager.shared.skView = skView!
		GameManager.shared.showMainMenu()
	}
	
	
	
	@IBAction func hostGame(_ sender: AnyObject?) {
		let hgvc = hostGameViewController
		let dialog = Dialog(contentViewController: hgvc)
		if dialog.runModal() == NSApplication.ModalResponse.OK.rawValue {
			let port = hgvc.serverPortField.integerValue
			let playerName = hgvc.playerNameField.stringValue
			GameManager.shared.hostGame(port: port, playerName: playerName) 
		}
	}
	
	
	@IBAction func joinGame(_ sender: AnyObject?) {
		
	}
	
}
