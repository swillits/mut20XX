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
		private let shuffler = GKARC4RandomSource()
		private var shapes: [Piece.Shape] = []
		
		mutating func nextShape() -> Piece.Shape {
			if shapes.isEmpty {
				shapes = Array<Array<Piece.Shape>>(repeating: Piece.Shape.all(), count: 4).joined().reversed()
				shapes = shuffler.arrayByShufflingObjects(in: shapes) as! [Piece.Shape]
			}
			return shapes.popLast()!
		}
	}
}
