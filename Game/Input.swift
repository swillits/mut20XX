//
//  Input.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Cocoa


enum PlayerInput: Int {
	case moveLeft
	case moveRight
	case moveDown
	case rotateLeft
	case rotateRight
	case drop
}




class PlayerInputState {
	
	/// True if the input was active at some point before processing the current frame. Cleared after each frame is processed.
	var activated: Bool = false
	
	/// Whether the input is still active right now. 
	var active: Bool = false
	
	/// Timestamp of when the input became active.
	var timestamp: TimeInterval = 0.0
	
	/// If the input was activated and deactivated before the frame processing started, this is the duration of how long it was active.
	/// eg, if wasActivated && !active, this duration is valid.
	var duration: TimeInterval = 0.0
	
	
	func reset() {
		activated = false
		active = false
		timestamp = 0.0
		duration = 0.0
	}
}



enum PlayerInputTrigger: Equatable {
	case keycode(UInt16)
	// mouse button
	// HID event etc
	
	static func ==(lhs: PlayerInputTrigger, rhs: PlayerInputTrigger) -> Bool {
		switch (lhs, rhs) {
		case (let .keycode(l), let .keycode(r)):
			return l == r
		}
	}
}



class PlayerInputMap {
	private let inputs: [PlayerInput: PlayerInputState] = [
		.moveDown:    PlayerInputState(),
		.moveLeft:    PlayerInputState(),
		.moveRight:   PlayerInputState(),
		.rotateLeft:  PlayerInputState(),
		.rotateRight: PlayerInputState(),
		.drop:        PlayerInputState()
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
	
	
	func activate(_ input: PlayerInput, time: TimeInterval) {
		self[input].active = true
		self[input].activated = true
		self[input].timestamp = time
		self[input].duration = 0.0
	}
	
	
	func deactivate(_ input: PlayerInput, time: TimeInterval) {
		self[input].active = false
		self[input].duration = time - self[input].timestamp
	}
	
	
	
	// -----------
	
	private var triggersMap: [PlayerInput: [PlayerInputTrigger]] = [:] 
	
	func triggers(for pi: PlayerInput) -> [PlayerInputTrigger] {
		return triggersMap[pi] ?? []
	}
	
	
	func setTriggers(_ triggers: [PlayerInputTrigger], for pi: PlayerInput) {
		triggersMap[pi] = triggers
	}
	
	
	func input(for trigger: PlayerInputTrigger) -> PlayerInput? {
		for (input, triggers) in triggersMap {
			if triggers.contains(trigger) {
				return input
			}
		}
		
		return nil
	}
}



extension PlayerInputTrigger {
	
	static func from(_ event: NSEvent) -> PlayerInputTrigger? {
		switch event.type {
		case .keyDown, .keyUp:
			return .keycode(event.keyCode)
		default:
			return nil
		}
	}
	
}

