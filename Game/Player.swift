//
//  Player.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation



struct Player {
	var clientID: ClientID
	var name: String
	
	var board = Board() 
	var score: Int = 0
	var isAlive: Bool = false
	var isReady: Bool = false
	var gameIsPrepared: Bool = false
	
	var currentPiece: Piece = Piece.placeholder
	var nextPiece: Piece = Piece.placeholder
	
	init(name: String, clientID: ClientID) {
		self.name = name
		self.clientID = clientID
	}
}
