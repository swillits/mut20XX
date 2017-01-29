//
//  ShapeGenerator.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation
import GameplayKit



extension Piece.Shape {
	struct Generator {
		
		mutating func nextShape() -> Piece.Shape {
			if shapes.isEmpty {
				reset()
			}
			
			return shapes.popLast()!
		}
		
		
		private let shuffler = GKARC4RandomSource()
		private var shapes: [Piece.Shape] = []
		
		private mutating func reset() {
			
			// The compiler refuses any form of this... why?
			// shapes = [Piece.Shape](repeating: Piece.Shape.all(), count: 4)
			
			shapes.removeAll()
			for _ in 1...4 {
				shapes.append(contentsOf: Piece.Shape.all())
			}
			
			shapes = shuffler.arrayByShufflingObjects(in: shapes) as! [Piece.Shape]
		}
		
	}
}
