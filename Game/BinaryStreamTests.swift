//
//  BinaryStreamTests.swift
//  BinaryStreamTests
//
//  Created by Seth Willits on 3/11/16.
//  Copyright © 2016 Araelium Group. All rights reserved.
//

import XCTest
@testable import MUT20XX

class BinaryStreamTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	
	
	let scenarioLittleEndian = (true, "TgAAAAEAeen2Qne+nxov3V5AhS77wB3+//jlZkHj////e9IEAAAQQOIBAAgamb4cAAAAeen2Qne+nxov3V5AAQIDBAAAAPCfmI4AAAAA")
	let scenarioBigEndian = (false, "AAAATgEAQvbpeUBe3S8an753hfsu//4dwP///+NBZuX4ewTSEAAAAAHiQAAAABy+mRoIQvbpeUBe3S8an753AQIDAAAABPCfmI4AAAAA")
	
	
	func testWriting_BE() {
		let _ = testWriting(littleEndian: scenarioBigEndian.0, dataStr: scenarioBigEndian.1)
	}
	
	
	func testWriting_LE() {
		let _ = testWriting(littleEndian: scenarioLittleEndian.0, dataStr: scenarioLittleEndian.1)
	}
	
	
	func testReading_BE() {
		testReading(littleEndian: scenarioBigEndian.0, data: NSData(base64Encoded: scenarioBigEndian.1, options: [.ignoreUnknownCharacters])!)
	}
	
	
	func testReading_LE() {
		testReading(littleEndian: scenarioLittleEndian.0, data: NSData(base64Encoded: scenarioLittleEndian.1, options: [.ignoreUnknownCharacters])!)
	}
	
	
	
	func testWriting(littleEndian: Bool, dataStr: String) -> NSData {
		let wdest = BinaryStream.DataDestination()
		do {
			let wbs = BinaryStream(destination: wdest)
			
			wbs.littleEndian = littleEndian
			
			do {
				try wbs.offsetPosition(4)
				try wbs.write(bool: true)
				try wbs.write(bool: false)
				try wbs.write(float: Float(123.456))
				try wbs.write(double: Double(123.456))
				try wbs.write(int8: Int8(-123))
				try wbs.write(int16: Int16(-1234))
				try wbs.write(int32: Int32(-123_456))
				try wbs.write(int64: Int64(-123_456_789_000))
				try wbs.write(uint8: UInt8(123))
				try wbs.write(uint16: UInt16(1234))
				try wbs.write(uint24: UInt32(1048576))
				try wbs.write(uint32: UInt32(123_456))
				try wbs.write(uint64: UInt64(123_456_789_000))
				try wbs.write(float32: Float32(123.456))
				try wbs.write(float64: Float64(123.456))
				try wbs.write(bytes: [UInt8]([1, 2, 3, 4]), length: 3)
				try wbs.writeUTF8String("\u{1F60E}") // smiley with sunglasses
				try wbs.writeUTF8String("")
				XCTAssert(wbs.isEndOfStream == true)
				
				try wbs.setPosition(0)
				try wbs.write(uint32: UInt32(wbs.length))
				XCTAssert(wbs.position == 4)
			} catch let e {
				XCTFail("Error when writing: \(e)")
			}
			
			XCTAssert(wdest.data.base64EncodedString(options: [.endLineWithLineFeed]) == dataStr)
			XCTAssert(wbs.position == 4)
			XCTAssert(wbs.length == 78)
			XCTAssert(wbs.isEndOfStream == false)
		}
		
		return wdest.data
	}
	
	
	
	func testReading(littleEndian: Bool, data: NSData) {
			
		let rdest = BinaryStream.DataDestination(data: data)
		let rbs = BinaryStream(destination: rdest)
		
		rbs.littleEndian = littleEndian
		
		
		XCTAssert(rdest.data == data)
		XCTAssert(rbs.length == UInt64(data.length))
		XCTAssert(rbs.isEndOfStream == false)
		XCTAssert(rbs.position == 0)
		
		
		do {
			try rbs.offsetPosition(4)
			XCTAssert(try rbs.readBool() == true)
			XCTAssert(try rbs.readBool() == false)
			XCTAssert(try rbs.readFloat() == Float(123.456))
			XCTAssert(try rbs.readDouble() == Double(123.456))
			XCTAssert(try rbs.readInt8() == Int8(-123))
			XCTAssert(try rbs.readInt16() == Int16(-1234))
			XCTAssert(try rbs.readInt32() == Int32(-123_456))
			XCTAssert(try rbs.readInt64() == Int64(-123_456_789_000))
			XCTAssert(try rbs.readUInt8() == UInt8(123))
			XCTAssert(try rbs.readUInt16() == UInt16(1234))
			XCTAssert(try rbs.readUInt24() == UInt32(1048576))
			XCTAssert(try rbs.readUInt32() == UInt32(123_456))
			XCTAssert(try rbs.readUInt64() == UInt64(123_456_789_000))
			XCTAssert(try rbs.readFloat32() == Float32(123.456))
			XCTAssert(try rbs.readFloat64() == Float64(123.456))
			
			
			var someBytes = [UInt8]([0, 0, 0, 99])
			try rbs.readBytes(&someBytes, length: 3)
			XCTAssert(someBytes[0] == 1)
			XCTAssert(someBytes[1] == 2)
			XCTAssert(someBytes[2] == 3)
			XCTAssert(someBytes[3] == 99)
			
			XCTAssert(try rbs.readUTF8String() == "\u{1F60E}") // smiley with sunglasses
			XCTAssert(try rbs.readUTF8String() == "")
			
			XCTAssert(rbs.isEndOfStream == true)
			
			try rbs.setPosition(0)
			XCTAssert(try rbs.readUInt32() == 78)
			XCTAssert(rbs.position == 4)
		} catch let e {
			XCTFail("Error when reading: \(e)")
		}
		
		
		// Ensure that reading past the end _does_ fail
		do {
			try! rbs.setPosition(rbs.length)
			let _ = try rbs.readUInt8()
			XCTFail("Did not catch reading past end")
		} catch {
			// Error expected
		}
	}
	
}
