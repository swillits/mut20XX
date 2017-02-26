//
//  JoinGameViewController.swift
//  Project
//
//  Created by Seth Willits on 2/26/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Cocoa

class JoinGameViewController: NSViewController {
	
	override var nibName: String? {
		return "JoinGameViewController"
	}
	
	override func viewDidAppear() {
		dialog?.title = "Join Game"
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}
	
}
