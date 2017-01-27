//
//  OccupancyMap.swift
//  MUT20XX
//
//  Created by Seth Willits on 1/27/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation



/// A 2-dimensional grid of cells/blocks where a cell can be occupied or unoccupied. Occupied cells have accompanying data indicating what occupies it.

struct OccupancyMap {
	// maybe make generic as to what it contains, but perhaps that's too general and we always just want the same thing anyway so far. Could use a map of bools only, and then a sibling structure containing data for occupied cells
	
	struct Cell {
		var filled: Bool
		var variety: BlockVariety
	}
	
	fileprivate var map = [[Cell]]()
	let width: Int
	let height: Int
	
	
	init(width: Int, height: Int) {
		self.width = width
		self.height = height
		
		let emptyCell = Cell(filled: false, variety: .a)
		let line: [Cell] = Array<Cell>(repeating: emptyCell, count: 5)
		
		for _ in 1...height {
			map.append(line)
		}
	}
	
	
	
	
	// fill, clear, test
	// copy from other map?
	
	
	
	
	
	// MARK: - Collision Detection
	
	// tests whether any occupied block in the given map is outside of the boundaries of the given board
	func hitsSidesOrBottom(map: OccupancyMap, x: Int, y: Int) -> Bool {
		// true if any occupied cell in map is x < 0 or x >= width/height
		// true if any occupied cell in map is y < 0
		return false
	}
	
	
	func spillsOverTop(map: OccupancyMap, x: Int, y: Int) -> Bool {
		// true if any occupied cell in map is y >= height
		return false
	}
	
	
	// tests whether the given map would collide with occupied cells
	func hitTest(map: OccupancyMap, x: Int, y: Int) -> Bool {
		guard !hitsSidesOrBottom(map: map, x: x, y: y) else { return true }
		return false
	}
	
}
