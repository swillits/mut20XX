//
//  OccupancyMap.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation


enum Rotation: Int {
	case north = 0, east = 1, south = 2, west = 3
	
	func nextClockwise() -> Rotation {
		return Rotation(rawValue: (self.rawValue + 1) % 4)!
	}
	
	func nextAnticlockwise() -> Rotation {
		return Rotation(rawValue: (self.rawValue - 1) % 4)!
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
		
		
		static func ==(lhs: Cell, rhs: Cell) -> Bool {
			switch (lhs, rhs) {
			case (.vacant, .vacant):
				return true
			case let (.filled(variety: l), .filled(variety: r)):
				return l == r
			default:
				return false
			}
		}
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
	
	
	static func ==(lhs: OccupancyMap, rhs: OccupancyMap) -> Bool {
		return lhs.width == rhs.width &&
			   lhs.height == rhs.height &&
			   lhs.map == rhs.map
	}
	
	
	
	
	// MARK: - Access
	
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
	
	
	
	
	// MARK: - Collision Detection
	
	struct Bounds: OptionSet {
		let rawValue: Int
		init(rawValue: Int) {
			self.rawValue = rawValue
		}
		
		static let north = Bounds(rawValue: 1 << 0)
		static let south = Bounds(rawValue: 1 << 1)
		static let east  = Bounds(rawValue: 1 << 2)
		static let west  = Bounds(rawValue: 1 << 3)
	}
	
	enum OverlaidCell {
		case outOfBounds(bounds: Bounds)
		case vacant
		case filled(variety: BlockVariety)
	}
	
	typealias OverlayCallback = (_ x: Int, _ y: Int, _ existing: OverlaidCell, _ incoming: Cell) -> ()
	
	// calls callback once for each cell in map,
	// with the coordinates in self,
	// the existing state of self at that position,
	// and the state of map at that point
	func overlay(_ map: OccupancyMap, x: Int, y: Int, action: OverlayCallback) {
		for theirY in 0..<map.height {
			let myY = y + theirY
			for theirX in 0..<map.width {
				let myX = x + theirX
				
				var bounds: Bounds = []
				if myX < 0       { bounds.insert(.west)  }
				if myX >= width  { bounds.insert(.east)  }
				if myY < 0       { bounds.insert(.north) }
				if myY >= height { bounds.insert(.south) }
				
				let existing: OverlaidCell
				if bounds.isEmpty {
					switch self[myX, myY] {
					case .vacant:
						existing = .vacant
					case .filled(variety: let variety):
						existing = .filled(variety: variety)
					}
				} else {
					existing = .outOfBounds(bounds: bounds)
				}
				
				action(myX, myY, existing, map[theirX, theirY])
			}
		}
	}
	
	struct Collision: OptionSet {
		let rawValue: Int
		init(rawValue: Int) {
			self.rawValue = rawValue
		}
	
		static let wall  = Collision(rawValue: 1 << 0)
		static let top   = Collision(rawValue: 1 << 1)
		static let block = Collision(rawValue: 1 << 2)
	}
	
	func collides(map: OccupancyMap, x: Int, y: Int) -> Collision {
		var collision: Collision = []
		overlay(map, x: x, y: y) { (_, _, existing, incoming) in
			switch (existing, incoming) {
			case (_, .vacant):
				break
			case (.vacant, .filled):
				break
			case (.filled, .filled):
				collision.insert(.block)
			case (.outOfBounds(bounds: let bounds), .filled):
				if bounds.contains(.north) {
					collision.insert(.top)
				}
				if !bounds.intersection([.south, .east, .west]).isEmpty {
					collision.insert(.wall)
				}
			}
		}
		return collision
	}
	
	
	
	
	
	// MARK: - Mutation
	
	mutating func insert(map: OccupancyMap, x: Int, y: Int) {
		overlay(map, x: x, y: y) { (myX, myY, existing, incoming) in
			switch (existing, incoming) {
			case (_, .vacant):
				break
			case (.vacant, .filled(variety: let blockVariety)):
				self[myX, myY] = .filled(variety: blockVariety)
			default:
				fatalError("Can't insert \(map) at (\(x),\(y)) in \(self)")
			}
		}
	}
	
	
	
	mutating func copyLines(from: CountableRange<Int>, to: CountableRange<Int>) {
		assert(from.count == to.count)
		assert(from.lowerBound >= 0)
		assert(from.upperBound <= height)
		assert(to.lowerBound >= 0)
		assert(to.upperBound <= height)
		
		if to.lowerBound > from.lowerBound {
			var srcLine = from.upperBound - 1
			var dstLine = to.upperBound - 1
			
			for _ in 1...from.count {
				copyLine(from: srcLine, to: dstLine)
				srcLine -= 1
				dstLine -= 1
			}
			
		} else {
			var srcLine = from.lowerBound
			var dstLine = to.lowerBound
			
			for _ in 1...from.count {
				copyLine(from: srcLine, to: dstLine)
				srcLine += 1
				dstLine += 1
			}
		}
	}
	
	
	
	mutating func copyLine(from srcLine: Int, to dstLine: Int) {
		assert((0..<height).contains(srcLine))
		assert((0..<height).contains(dstLine))
		
		for x in 0..<width {
			self[x, dstLine] = self[x, srcLine]
		}
	}
	
	
	
	mutating func vacate(lines: IndexSet) {
		for y in lines {
			for x in 0..<width {
				self[x, y] = Cell.vacant
			}
		}
	}
	
	
	
	/// Shifts the given line and all those above upwards by `count` lines, leaving empty lines behind.
	mutating func shiftUp(startingLine: Int, count: Int) {
		assert(startingLine >= 0)
		assert(startingLine < height - 1)
		assert(startingLine + count <= height)
		
		let numToCopy = height - (startingLine + count)
		if numToCopy > 0 {
			copyLines(from: startingLine ..< (startingLine + numToCopy), to: (height - numToCopy)..<height)
		}
		vacate(lines: IndexSet(integersIn: startingLine ..< (startingLine + count)))
	}
	
	
	
	/// Shifts the given line and all those above downwards by `count` lines, leaving empty lines behind.
	private mutating func shiftDown(startingLine: Int, count: Int) {
		assert(startingLine - count >= 0)
		assert(startingLine <= height)
		
		let numToCopy = height - startingLine
		if numToCopy > 0 {
			copyLines(from: startingLine ..< (startingLine + numToCopy), to: (startingLine - count)..<(startingLine - count + numToCopy))
		}
		vacate(lines: IndexSet(integersIn: (startingLine - count + numToCopy) ..< height))
	}
	
	
	/// Erases lines, shifting lines above downwards, and shifting in blank lines from the top
	mutating func eraseLines(_ indexSet: IndexSet) {
		for line in indexSet.reversed() {
			shiftDown(startingLine: line + 1, count: 1)
		}
	}
}
