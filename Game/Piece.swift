//
//  Piece.swift
//  MUT20XX
//
//  Created by Seth Willits on 1/27/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation



struct Piece {
	
	var shape: Shape
	var position: Position
	var rotation: Rotation
	
	var occupancyMap: OccupancyMap {
		return shape.occupancyMap.rotated(to: rotation)
	}
	
	
	
	
	enum Shape {
		case line, square, L, r, z, s
		
		var occupancyMap: OccupancyMap {
			switch self {
			case .line:
				return OccupancyMap(width: 4, height: 4,
					nil, nil,  .a, nil,
					nil, nil,  .a, nil,
					nil, nil,  .a, nil,
					nil, nil,  .a, nil)
			case .square:
				return OccupancyMap(width: 4, height: 4,
					nil, nil, nil, nil,
					nil,  .b,  .b, nil,
					nil,  .b,  .b, nil,
					nil, nil, nil, nil)
			case .L:
				return OccupancyMap(width: 4, height: 4,
					nil,  .c, nil, nil,
					nil,  .c, nil, nil,
					nil,  .c,  .c, nil,
					nil, nil, nil, nil)
			case .r:
				return OccupancyMap(width: 4, height: 4,
					nil, nil,  .d, nil,
					nil, nil,  .d, nil,
					nil,  .d,  .d, nil,
					nil, nil, nil, nil)
			case .s:
				return OccupancyMap(width: 4, height: 4,
					nil, nil, nil, nil,
					nil, nil,  .e,  .e,
					nil,  .e,  .e, nil,
					nil, nil, nil, nil)
			case .z:
				return OccupancyMap(width: 4, height: 4,
					nil, nil, nil, nil,
					 .f,  .f, nil, nil,
					nil,  .f,  .f, nil,
					nil, nil, nil, nil)
			}
		}
	}
	
	
	// note that x and y can both be negative, and y can be greater than the height of the board
	struct Position {
		var x: Int
		var y: Int
	}
	
}

