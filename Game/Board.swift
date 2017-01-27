//
//  Board.swift
//  MUT20XX
//
//  Created by Seth Willits on 1/27/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation



struct Board {
	
	// size
	// occupancy map
	// isValidMove(piece: Piece, position: Piece.Position)
	// performAction(action)
	
	// private:
	// eraseLine(which line)
	// erase all
	// fillWithBricks
	// shiftLinesUpwards(delta)
	// addLineToBottom(line)
	// placePiece()
	
}



// Easily encodable and self-contained. Contains all info to perform a move on a given board. Suitable for transmission.
enum BoardAction {
	
	case eraseLine(Int)
	case eraseAll
	case fillWithBricks
	case shiftLinesUpwards(startingLine: Int, count: Int)
	case addLineToBottom(Line)
	case placePiece(piece: Piece, position: Piece.Position)
}



// each variety has its own color
enum BlockVariety {
	case a, b, c, d, e, f
}



/// The contents of a line of a board, suitable for transmission.
struct Line {
	// Simply a 1 x 10 occupancy map?
}




