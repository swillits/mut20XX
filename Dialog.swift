//
//  Dialog.swift
//  Project
//
//  Created by Seth Willits on 2/26/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Cocoa

class Dialog: NSPanel {
	
	init(contentViewController: NSViewController) {
		super.init(contentRect: NSRect.zero, styleMask: .titled, backing: .buffered, defer: false)
		self.contentViewController = contentViewController
	}
	
	func runModal() -> Int {
		return NSApp.runModal(for: self)
	}
	
	func stop(_ response: NSModalResponse) {
		NSApp.stopModal(withCode: response)
	}
}


extension NSViewController {
	
	var dialog: Dialog? {
		return view.window as? Dialog
	}
	
}

