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
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		window.contentView?.addSubview(sceneViewController.view)
		sceneViewController.showMainMenu()
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		
	}
	
	
	
	@IBAction func newGame(_ sender: Any?) {
		
	}
}
