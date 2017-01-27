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
	// isPositionOccupied(piece: Piece, position: Piece.Position)
	// performAction(action)
	
	// private:
	// eraseLine(which line)
	// erase all
	// fillWithBricks
	// shiftLinesUpwards(delta)
	// addLineToBottom(line)
	// placePiece()
	
	
	/// Is the proposed position for the piece occupied by any blocks, or out of bounds.
	/// - Returns: true if the piece will collide with the board's walls or another block
	func isPositionOccupied(piece: Piece, position: Piece.Position) -> Bool {
		return false
		/*
		// is the shape allowed to be at %position? Returns true if the shape will
		// not collide with the arena walls or another block
		function isValidMove( %delta, %shape )
		{
		   // We need to add a test in here to check for collisions with 
		   // other blocks at the base of the game well, however for now we'll just
		   // make a simple test for the walls and return to this later in the tutorial.
		   %newX = getWord(%delta,0) + getWord(%shape.position, 0);
		   %newY = getWord(%delta,1) + getWord(%shape.position, 1);
		   %map = PlayerTetrisBoard;
		   
		   for (%x = 0; %x < $GAME::SHAPES::SIZEX; %x++) {
			  for (%y = 0; %y < $GAME::SHAPES::SIZEX; %y++) {
				 if (%shape.chunk[%x, %y, %shape.blockRotation] != 0) {
					// has the block left the confines of the arena? Only really
					// possible without a collision if you use broken shapes or
					// move left and rotate very quickly at the start :P
					if ( %newX+%x <= 0 || %newX + %x >= %map.getTileCountX()-1)
					   return false;
					   
					// does the block collide with an existing block?
					%data = %map.getTileCustomData(%newX+%x SPC %newY+%y);
					if (%data !$= "" && %data !$= $GAME::MAP::MOVING_TILE)            
					   return false;      
				 }
			  }
		   }
		   
		   return true;
		}
		*/
		
	}
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




