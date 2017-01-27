//
//  Piece.swift
//  MUT20XX
//
//  Created by Seth Willits on 1/27/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation



struct Piece {
	
	var position: Position
	var rotation: Rotation
	
	// variety: BlockVariety ? (or being in the occupancy map is enough)
	// occupancy map (for a given rotation) 4 x 4 area
	
	
	
	
	enum Shape {
		case line, block, leftL, rightL, z, s
	}
	
	
	enum Rotation: Int {
		case a = 0, b = 1, c = 2, d = 3
		
		func next() -> Rotation {
			return Rotation(rawValue: (self.rawValue + 1) % 4)!
		}
	}
	
	
	// note that x and y can both be negative, and y can be greater than the height of the board
	struct Position {
		var x: Int
		var y: Int
	}
	
}

