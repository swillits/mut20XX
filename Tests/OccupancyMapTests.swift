import XCTest

@testable import MUT20XX

class OccupancyMapTests: XCTestCase {

    func testExample() {
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

}
