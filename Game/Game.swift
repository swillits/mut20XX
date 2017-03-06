//
//  Game.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation

struct Game {
	static let minimumTimeBetweenHorizontalMoves: TimeInterval = 0.1
	static let minimumTimeBetweenVerticalMoves: TimeInterval = 0.1
	static let normalTimeBetweenFalls: TimeInterval = 1.0
	static let minimumTimeBetweenRotations: TimeInterval = 0.15
	
	static let maxPlayers = 5
	static let minPiecePosition = Piece.Position(-4, -4)
	static let maxPiecePosition = Piece.Position(Board.width, Board.height)
}
