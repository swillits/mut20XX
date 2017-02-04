//
//  Input.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation


enum PlayerInput: Int {
	case moveLeft
	case moveRight
	case moveDown
	case rotateLeft
	case rotateRight
	case drop
}




class PlayerInputState {
	
	/// Keyboard keycode to trigger it.
	// Could be pulled out of here, made into a struct with device + button IDs suitable for HID etc, and then have multiple triggers for each Input.
	var keycode: UInt16
	
	
	/// True if the input was active at some point before processing the current frame. Cleared after each frame is processed.
	var activated: Bool = false
	
	/// Whether the input is still active right now. 
	var active: Bool = false
	
	/// Timestamp of when the input became active.
	var timestamp: TimeInterval = 0.0
	
	/// If the input was activated and deactivated before the frame processing started, this is the duration of how long it was active.
	/// eg, if wasActivated && !active, this duration is valid.
	var duration: TimeInterval = 0.0
	
	
	init(keycode: UInt16) {
		self.keycode = keycode
	}
	
	
	func reset() {
		activated = false
		active = false
		timestamp = 0.0
		duration = 0.0
	}
}



class PlayerInputMap {
	fileprivate let inputs: [PlayerInput: PlayerInputState] = [
		.moveDown:    PlayerInputState(keycode: 0),
		.moveRight:   PlayerInputState(keycode: 0),
		.rotateLeft:  PlayerInputState(keycode: 0),
		.rotateRight: PlayerInputState(keycode: 0),
		.drop:        PlayerInputState(keycode: 0)
	]
	
	
	subscript(_ input: PlayerInput) -> PlayerInputState {
		return inputs[input]!
	}
	
	
	func clearActivated() {
		for state in inputs.values {
			state.activated = false
			state.duration = 0.0
			if !state.active {
				state.timestamp = 0.0
			}
		}
	}
	
	
	func reset() {
		for state in inputs.values {
			state.reset()
		}
	}
}





