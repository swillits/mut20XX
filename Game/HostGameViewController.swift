//
//  HostGameViewController.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Cocoa

class HostGameViewController: NSViewController {
	
	@IBOutlet weak var serverAddressField: NSTextField!
	@IBOutlet weak var serverPortField: NSTextField!
	@IBOutlet weak var playerNameField: NSTextField!
	
	var result: Bool = false
	
	override var nibName: NSNib.Name? {
		return NSNib.Name("HostGameViewController")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		playerNameField.stringValue = Prefs.playerName.value
		serverPortField.stringValue = "\(Prefs.serverPort.value)"
	}
	
	
	override func viewDidAppear() {
		dialog?.makeFirstResponder(playerNameField)
		dialog?.title = "Host Game"
	}
	
	
	@IBAction func hostGame(_ sender: AnyObject?) {
		Prefs.playerName.value = playerNameField.stringValue
		Prefs.serverPort.value = serverPortField.integerValue
		dialog?.stop(.OK)
	}
	
	
	@IBAction func cancelAction(_ sender: AnyObject?) {
		dialog?.stop(.cancel)
	}
	
	
}
