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
	
	
	func applicationWillTerminate(_ aNotification: Notification) {
		
	}
	
	
	@IBAction func hostGame(_ sender: AnyObject?) {
		let dialog = Dialog(contentViewController: hostGameViewController)
		if dialog.runModal() == NSModalResponseOK {
			
		}
	}
	
	@IBAction func joinGame(_ sender: AnyObject?) {
		
	}
}
