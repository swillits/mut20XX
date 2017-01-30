//
//  Player.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation



typealias PlayerID = String

struct Player {
	var id: PlayerID
	var name: String
	var state = PlayerState()
	
	init(id: PlayerID, name: String) {
		self.id = id
		self.name = name
	}
}


struct PlayerState {
	var board = Board() 
	var score: Int = 0
	var isAlive: Bool = false
	var ready: Bool = false
	var gameLoaded: Bool = false
	
	var currentPice: Piece = Piece.placeholder
	var nextPiece: Piece = Piece.placeholder
}


struct LocalPlayerState {
	var holdingLeft: Bool = false
	var holdingRight: Bool = false
	var lastHorizontalMovementTime: TimeInterval = 0.0
}
