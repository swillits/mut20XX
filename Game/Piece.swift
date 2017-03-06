//
//  Piece.swift
//  MUT20XX
//
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
	
	
	static var placeholder: Piece {
		return Piece(shape: .I, position: Piece.Position(0, 0), rotation: .north)
	}
	
	
	
	
	enum Shape: Int {
		// standard piece names (see wikipedia)
		// uppercase in defiance of swift convention
		// because the names make no sense in lowercase
		case I, J, L, O, S, T, Z
		
		static let width = 4
		static let height = 4
		var occupancyMap: OccupancyMap {
			switch self {
			case .I:
				return OccupancyMap(width: 4, height: 4,
					nil, nil,  .a, nil,
					nil, nil,  .a, nil,
					nil, nil,  .a, nil,
					nil, nil,  .a, nil)
			case .J:
				return OccupancyMap(width: 4, height: 4,
					nil, nil,  .b, nil,
					nil, nil,  .b, nil,
					nil,  .b,  .b, nil,
					nil, nil, nil, nil)
			case .L:
				return OccupancyMap(width: 4, height: 4,
					nil,  .c, nil, nil,
					nil,  .c, nil, nil,
					nil,  .c,  .c, nil,
					nil, nil, nil, nil)
			case .O:
				return OccupancyMap(width: 4, height: 4,
					nil, nil, nil, nil,
					nil,  .d,  .d, nil,
					nil,  .d,  .d, nil,
					nil, nil, nil, nil)
			case .S:
				return OccupancyMap(width: 4, height: 4,
					nil, nil, nil, nil,
					nil, nil,  .e,  .e,
					nil,  .e,  .e, nil,
					nil, nil, nil, nil)
			case .T:
				return OccupancyMap(width: 4, height: 4,
					nil, nil, nil, nil,
					nil,  .f,  .f,  .f,
					nil, nil,  .f, nil,
					nil, nil, nil, nil)
			case .Z:
				return OccupancyMap(width: 4, height: 4,
					nil, nil, nil, nil,
					 .g,  .g, nil, nil,
					nil,  .g,  .g, nil,
					nil, nil, nil, nil)
			}
		}
		
		
		static func all() -> [Shape] {
			return [.I, .J, .L, .O, .S, .T, .Z]
		}
	}
	
	
	// note that x and y can both be negative, and y can be greater than the height of the board
	// 0, 0 is the bottom left valid cell in the board.
	// Should either be Board.Position or top level
	struct Position {
		var x: Int
		var y: Int
		
		init(_ x: Int, _ y: Int) {
			self.x = x
			self.y = y
		}
	}
	
}

