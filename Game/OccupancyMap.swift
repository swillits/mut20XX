//
//  OccupancyMap.swift
//  MUT20XX
//
//  Created by Seth Willits on 1/27/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation


enum Rotation: Int {
	case north = 0, east = 1, south = 2, west = 3
	
	func next() -> Rotation {
		return Rotation(rawValue: (self.rawValue + 1) % 4)!
	}
	
	func transform(size: (w: Int, h: Int)) -> (w: Int, h: Int) {
		switch self {
		case .north, .south:
			return (w: size.w, h: size.h)
		case .east, .west:
			return (w: size.h, h: size.w)
		}
	}
	
	func transform(position: (x: Int, y: Int), in size: (w: Int, h: Int)) -> (x: Int, y: Int) {
		switch self {
		case .north:
			return (x: position.x, y: position.y)
		case .east:
			return (x: size.h - 1 - position.y, y: position.x)
		case .south:
			return (x: size.w - 1 - position.x, y: size.h - 1 - position.y)
		case .west:
			return (x: position.y, y: size.w - 1 - position.x)
		}
	}
	
}

/// A 2-dimensional grid of cells/blocks where a cell can be occupied or unoccupied. Occupied cells have accompanying data indicating what occupies it.

struct OccupancyMap: Equatable {
	// maybe make generic as to what it contains, but perhaps that's too general and we always just want the same thing anyway so far. Could use a map of bools only, and then a sibling structure containing data for occupied cells
	
	enum Cell: Equatable {
		case vacant
		case filled(variety: BlockVariety)
	}
	
	fileprivate var map: [Cell]
	let width: Int
	let height: Int
	
	
	init(width: Int, height: Int) {
		self.width = width
		self.height = height
		map = Array(repeating: .vacant, count: width * height)
	}
	
	init(width: Int, height: Int, _ blocks: BlockVariety?...) {
		self.width = width
		self.height = height
		self.map = blocks.map {
			if let variety = $0 {
				return .filled(variety: variety)
			} else {
				return .vacant
			}
		}
	}
	
	private(set) subscript(x: Int, y: Int) -> Cell {
		get {
			assert(x >= 0)
			assert(x < width)
			assert(y >= 0)
			assert(y < height)
			return map[y * width + x]
		}
		set {
			assert(x >= 0)
			assert(x < width)
			assert(y >= 0)
			assert(y < height)
			map[y * width + x] = newValue
		}
	}
	
	func rotated(to rotation: Rotation) -> OccupancyMap {
		let (w: w, h: h) = rotation.transform(size: (w: width, h: height))
		
		var result = OccupancyMap(width: w, height: h)
		for x in 0..<width {
			for y in 0..<height {
				let (x: tx, y: ty) = rotation.transform(position: (x: x, y: y), in: (w: width, h: height))
				result[tx, ty] = self[x, y]
			}
		}
		
		return result
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

func ==(lhs: OccupancyMap.Cell, rhs: OccupancyMap.Cell) -> Bool {
	switch (lhs, rhs) {
	case (.vacant, .vacant):
		return true
	case let (.filled(variety: l), .filled(variety: r)):
		return l == r
	default:
		return false
	}
}

func ==(lhs: OccupancyMap, rhs: OccupancyMap) -> Bool {
	return lhs.width == rhs.width &&
		   lhs.height == rhs.height &&
		   lhs.map == rhs.map
}
