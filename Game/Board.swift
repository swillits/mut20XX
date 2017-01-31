//
//  Board.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation



struct Board {
	
	static let width = 10
	static let height = 20
	
	fileprivate var map = OccupancyMap(width: width, height: height)
	
	
	
	
	// MARK: - Info
	
	func doesPositionCollide(piece: Piece, position: Piece.Position) -> Bool {
		let collision = map.collides(map: piece.occupancyMap, x: position.x, y: position.y)
		return collision.contains(.wall)
	}
	
	
	func finalPositionIfDropped(piece: Piece, position: Piece.Position) -> Piece.Position {
		var y = position.y
		
		while true {
			let collision = map.collides(map: piece.occupancyMap, x: position.x, y: position.y)
			if collision.contains(.wall) {
				precondition(y < position.y, "The piece collides at the given position meaning the piece should have already been placed and this indicates an error.")
				return Piece.Position(x: position.x, y: y + 1)
			}
			
			y -= 1
		}
		
		preconditionFailure("Should always collide with the bottom wall.")
	}
	
	
	
	
	// MARK: - Actions
	
	mutating func perform(action: BoardAction) {
		switch action {
		case let .eraseLines(lines):
			map.eraseLines(lines)
			
		case let .addLinesToBottom(lines):
			addLinesToBottom(lines: lines)
			
		case let .placePiece(piece, position):
			map.insert(map: piece.occupancyMap, x: position.x, y: position.y)
		}
	}
	
	
	private mutating func addLinesToBottom(lines: [Line]) {
		map.shiftUp(startingLine: 0, count: lines.count)
		for li in 0..<lines.count {
			map.insert(map: lines[li].occupancyMap, x: 0, y: li)
		}
	}
	
	
	mutating func removeCompletedLines() -> IndexSet {
		// Inefficient in that only lines with touched by a placed piece should be examined, but keeping this a separate step for now
		
		var completedLineIndexes = IndexSet()
		for y in 0..<map.height {
			var complete = true
			
			for x in 0..<map.width {
				if case .vacant = map[x, y] {
					complete = false
					break
				}
			}
			
			if complete {
				completedLineIndexes.insert(y)
			}
		}
		
		map.eraseLines(completedLineIndexes)
		return completedLineIndexes
	}
}




// MARK: - Types


// Easily encodable and self-contained. Contains all info to perform a move on a given board. Suitable for transmission.
enum BoardAction {
	case eraseLines(IndexSet)
	case addLinesToBottom([Line])
	case placePiece(piece: Piece, position: Piece.Position)
}



// each variety has its own color
enum BlockVariety: Equatable {
	case a, b, c, d, e, f, g
}



/// The contents of a line of a board, suitable for transmission.
struct Line {
	var occupancyMap = OccupancyMap(width: Board.width, height: 1)
}




