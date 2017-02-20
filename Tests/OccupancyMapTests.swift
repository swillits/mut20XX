import XCTest

@testable import MUT20XX

class OccupancyMapTests: XCTestCase {

    func testRotation() {
		let line = OccupancyMap(width: 4, height: 4,
			nil, nil,  .a, nil,
			nil, nil,  .a, nil,
			nil, nil,  .a, nil,
			nil, nil,  .a, nil)

        XCTAssertEqual(line.rotated(to: .north), line)
        XCTAssertEqual(line.rotated(to: .east), OccupancyMap(width: 4, height: 4,
			nil, nil, nil, nil,
			nil, nil, nil, nil,
			 .a,  .a,  .a,  .a,
			nil, nil, nil, nil))
        XCTAssertEqual(line.rotated(to: .south), OccupancyMap(width: 4, height: 4,
			nil,  .a, nil, nil,
			nil,  .a, nil, nil,
			nil,  .a, nil, nil,
			nil,  .a, nil, nil))
        XCTAssertEqual(line.rotated(to: .west), OccupancyMap(width: 4, height: 4,
			nil, nil, nil, nil,
			 .a,  .a,  .a,  .a,
			nil, nil, nil, nil,
			nil, nil, nil, nil))
    }
	
	
	func testCollision() {
		var board = OccupancyMap(width: 4, height: 4,
			nil, nil, nil, nil,
			nil, nil, nil, nil,
			nil, nil, nil, nil,
			nil, nil, nil, nil)
		
		board.insert(map: Piece.Shape.I.occupancyMap.rotated(to: .east), x: 0, y: -1)
		XCTAssertEqual(board, OccupancyMap(width: 4, height: 4,
			nil, nil, nil, nil,
			nil, nil, nil, nil,
			nil, nil, nil, nil,
			 .a,  .a,  .a,  .a))
		
		board.insert(map: Piece.Shape.L.occupancyMap, x: -1, y: 0)
		XCTAssertEqual(board, OccupancyMap(width: 4, height: 4,
			 .c, nil, nil, nil,
			 .c, nil, nil, nil,
			 .c,  .c, nil, nil,
			 .a,  .a,  .a,  .a))
		
		let o = Piece.Shape.O.occupancyMap
		XCTAssertEqual([             .block], board.collides(map: o, x:  0, y:  0))
		XCTAssertEqual([.top               ], board.collides(map: o, x:  0, y:  2))
		XCTAssertEqual([      .wall, .block], board.collides(map: o, x:  0, y: -2))
		XCTAssertEqual([      .wall        ], board.collides(map: o, x:  2, y:  0))
		XCTAssertEqual([.top, .wall, .block], board.collides(map: o, x: -2, y:  2))
		XCTAssertEqual([.top, .wall        ], board.collides(map: o, x:  2, y:  2))
		XCTAssertEqual([      .wall, .block], board.collides(map: o, x:  2, y: -2))
	}

	
	func testShiftUp() {
		var board = OccupancyMap(width: 1, height: 7,
			 .a, .b, .c, .d, .e, .f, .g)
		
		board.shiftUp(startingLine: 0, count: 1)
		XCTAssertEqual(board, OccupancyMap(width: 1, height: 7, .b, .c, .d, .e, .f, .g, nil))
		
		board.shiftUp(startingLine: 3, count: 2)
		XCTAssertEqual(board, OccupancyMap(width: 1, height: 7, .d, .e, nil, nil, .f, .g, nil))
		
		board = OccupancyMap(width: 1, height: 7,
			 .a, .b, .c, .d, .e, .f, .g)
		board.shiftUp(startingLine: 0, count: 7)
		XCTAssertEqual(board, OccupancyMap(width: 1, height: 7,
			nil, nil, nil, nil, nil, nil, nil))
	}
	
	
	
	func testEraseLines() {
		var board = OccupancyMap(width: 1, height: 7,
			.a, .b, .c, .d, .e, .f, .g)
		
		board.eraseLines([2, 3])
		XCTAssertEqual(board, OccupancyMap(width: 1, height: 7,
			nil, nil, .a, .b, .c, .f, .g))
		
		board.eraseLines([0, 3])
		XCTAssertEqual(board, OccupancyMap(width: 1, height: 7,
			nil, nil, nil, nil, .a, .c, .f))
		
		board = OccupancyMap(width: 1, height: 7,
			.a, .b, .c, .d, .e, .f, .g)
		board.eraseLines(IndexSet(integersIn: 0..<7))
		XCTAssertEqual(board, OccupancyMap(width: 1, height: 7,
			nil, nil, nil, nil, nil, nil, nil))
	}
}
