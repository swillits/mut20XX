//
//  Dialog.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Cocoa

class Dialog: NSPanel {
	
	init(contentViewController: NSViewController) {
		super.init(contentRect: NSRect.zero, styleMask: NSWindow.StyleMask.titled, backing: .buffered, defer: false)
		self.contentViewController = contentViewController
	}
	
	func runModal() -> Int {
		return NSApp.runModal(for: self).rawValue
	}
	
	func stop(_ response: NSApplication.ModalResponse) {
		NSApp.stopModal(withCode: response)
		orderOut(nil)
	}
}


extension NSViewController {
	
	var dialog: Dialog? {
		return view.window as? Dialog
	}
	
}

