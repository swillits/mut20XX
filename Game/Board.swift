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
	static let initialPiecePosition = Piece.Position(3, 20)
	
	fileprivate(set) var map = OccupancyMap(width: width, height: height)
	
	
	
	
	// MARK: - Info
	
	func doesPositionCollide(piece: Piece) -> Bool {
		let collision = map.collides(map: piece.occupancyMap, x: piece.position.x, y: piece.position.y)
		return collision.contains(.wall) || collision.contains(.block)
	}
	
	
	func doesPieceSpillOverTop(piece: Piece) -> Bool {
		let collision = map.collides(map: piece.occupancyMap, x: piece.position.x, y: piece.position.y)
		return collision.contains(.top)
	}
	
	
	func finalPositionIfDropped(piece: Piece) -> Piece.Position {
		precondition(!map.collides(map: piece.occupancyMap, x: piece.position.x, y: piece.position.y).contains(.wall), "The piece collides at the given position meaning the piece should have already been placed and this indicates an error.")
		
		for y in (Game.minPiecePosition.y ..< piece.position.y).reversed() {
			let collision = map.collides(map: piece.occupancyMap, x: piece.position.x, y: y) 
			if collision.contains(.wall) || collision.contains(.block) {
				return Piece.Position(piece.position.x, y + 1)
			}
		}
		
		preconditionFailure("Should always collide with the bottom wall.")
	}
	
	
	
	
	// MARK: - Actions
	
	mutating func perform(action: BoardAction) {
		switch action {
		case let .eraseLines(lines):
			map.eraseLines(lines)
			
		case let .addLinesToBottom(lines):
			addLinesToBottom(lines)
			
		case let .placePiece(piece):
			map.insert(map: piece.occupancyMap, x: piece.position.x, y: piece.position.y)
		}
	}
	
	
	private mutating func addLinesToBottom(_ lines: [Line]) {
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
	case placePiece(Piece)
}



// each variety has its own color
enum BlockVariety: Equatable {
	case a, b, c, d, e, f, g
	case wall
}



/// The contents of a line of a board, suitable for transmission.
struct Line {
	var occupancyMap = OccupancyMap(width: Board.width, height: 1)
}




