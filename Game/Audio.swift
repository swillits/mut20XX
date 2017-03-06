//
//  Audio.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation


// Single music track looping
// Fire and forget sound effects

protocol Sound {
	func play()
	// var filePath: String { get }
}


extension Sound {
	func play() {
		// call to sound manager to play it
	}
}


enum InterfaceSound: Sound {
	case buttonHover
	case buttonClick
	case buttonRelease
}


enum GameSound: Sound {
	case moveBlock
	case rotateBlock
	case dropBlock
	case completeLine
	case completeFourLines
	case suckLines
	case collision
	case newLevel
	case gameOver
	case wonGame
}
