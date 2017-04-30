//
//  BinaryStream.swift
//  BinaryStream
//
//  Created by Seth Willits on 3/11/16.
//  Copyright © 2016-2017 Araelium Group. All rights reserved.
//

import Foundation




class BinaryStream {
	
	private var _destination: BinaryStreamDestination
	fileprivate var destination: BinaryStreamDestination {
		return _destination
	}
	
	init(destination: BinaryStreamDestination) {
		self._destination = destination
	}
	
	
	
	
	
	// MARK: - Properties
	
	fileprivate let isHostLittleEndian = (UInt32(littleEndian: 1) == 1)
	
	/// Determines whether the numeric types are written and read in big endian or little form. This can be changed at any time.
	var littleEndian: Bool = true
	
	
	/// Returns whether the current position is at the end of the stream
	var isEndOfStream: Bool {
		return destination.isEndOfStream
	}
	
	
	/// The length of the data in the stream.
	var length: Int {
		get {
			return destination.length
		}
	}
	
	
	/// The current position of the data in the stream. Reading and writing moves the position.
	var position: Int {
		get {
			return destination.position
		}
	}
	
	
	/// Depending on the stream type, setting the position past the length of the stream may:
	/// a) fail and throw (eg, when using file destination type)
	/// b) grow the length of the stream (eg, when using data destination type) 
	func setPosition(_ pos: Int) throws {
		try destination.setPosition(pos)
	}
	
	
	/// A simple convenience method for setPosition(position + offset)
	func offsetPosition(_ offset: Int) throws {
		try setPosition(position + offset)
	}
	
	
	// MARK: - Reading
	
	func readBytes(_ bytes: UnsafeMutableRawPointer, length: Int) throws {
		try destination.read(bytes: bytes, length: length)
	}
	
	
	func readData(length readLength: Int) throws -> Data {
		var data = Data(count: length)
		try data.withUnsafeMutableBytes { (pointer: UnsafeMutablePointer<Int8>)  in
			try destination.read(bytes: pointer, length: length)
		}
		return data
	}
	
	
	func readBool() throws -> Bool {
		let b = try readUInt8()
		return b != 0
	}
	
	
	func readFloat() throws -> Float {
		var x: UInt32 = 0
		try destination.read(bytes: &x, length: 4)
		x = (littleEndian == isHostLittleEndian) ? x : x.byteSwapped
		return Float(bitPattern: x)
	}
	
	
	func readDouble() throws -> Double {
		var x: UInt64 = 0
		try destination.read(bytes: &x, length: 8)
		x = (littleEndian == isHostLittleEndian) ? x : x.byteSwapped
		return Double(bitPattern: x)
	}
	
	
	func readFloat32() throws -> Float32 {
		return Float32(try readFloat())
	}
	
	
	func readFloat64() throws -> Float64 {
		return Float64(try readDouble())
	}
	
	
	func readUInt8() throws -> UInt8 {
		var x: UInt8 = 0
		try destination.read(bytes: &x, length: 1)
		return x
	}
	
	
	func readUInt16() throws -> UInt16 {
		var x: UInt16 = 0
		try destination.read(bytes: &x, length: 2)
		return (littleEndian == isHostLittleEndian) ? x : x.byteSwapped 
	}
	
	
	func readUInt24() throws -> UInt32 {
		var x: UInt32 = 0
		try destination.read(bytes: &x, length: 3)
		
		if littleEndian == isHostLittleEndian {
			return x
		}
		
		return x.byteSwapped >> 8
	}
	
	
	func readUInt32() throws -> UInt32 {
		var x: UInt32 = 0
		try destination.read(bytes: &x, length: 4)
		return (littleEndian == isHostLittleEndian) ? x : x.byteSwapped
	}
	
	
	func readUInt64() throws -> UInt64 {
		var x: UInt64 = 0
		try destination.read(bytes: &x, length: 8)
		return (littleEndian == isHostLittleEndian) ? x : x.byteSwapped
	}
	
	
	func readInt8() throws -> Int8 {
		return Int8(bitPattern: try readUInt8())
	}
	
	
	func readInt16() throws -> Int16 {
		return Int16(bitPattern: try readUInt16())
	}
	
	
	func readInt32() throws -> Int32 {
		return Int32(bitPattern: try readUInt32())
	}
	
	
	func readInt64() throws -> Int64 {
		return Int64(bitPattern: try readUInt64())
	}
}





class MutableBinaryStream: BinaryStream {
	
	fileprivate var mutableDestination: MutableBinaryStreamDestination {
		return destination as! MutableBinaryStreamDestination
	}
	
	init(destination: MutableBinaryStreamDestination) {
		super.init(destination: destination)
	}
	
	
	func write(data: Data) throws {
		try data.withUnsafeBytes { (ptr: UnsafePointer<Int8>) in
			try mutableDestination.write(bytes: ptr, length: data.count)
		}
	}
	
	
	func write(bytes: UnsafeRawPointer, length: Int) throws {
		try mutableDestination.write(bytes: bytes, length: length)
	}
	
	
	func write(float value: Float) throws {
		try write(float32: Float32(value))
	}
	
	
	func write(double value: Double) throws {
		try write(float64: Float64(value))
	}
	
	
	func write(float32 value: Float32) throws {
		var x = value.bitPattern
		x = littleEndian ? x.littleEndian : x.bigEndian
		try write(bytes: &x, length: 4)
	}
	
	
	func write(float64 value: Float64) throws {
		var x = value.bitPattern
		x = littleEndian ? x.littleEndian : x.bigEndian
		try write(bytes: &x, length: 8)
	}
	
	
	func write(bool value: Bool) throws {
		var x: Int8 = value ? 1 : 0
		try write(bytes: &x, length: 1)
	}
	
	
	func write(uint8 value: UInt8) throws {
		var x = value
		try write(bytes: &x, length: 1)
	}
	
	
	func write(uint16 value: UInt16) throws {
		var x = littleEndian ? value.littleEndian : value.bigEndian
		try write(bytes: &x, length: 2)
	}
	
	
	func write(uint24 value: UInt32) throws {
		var x = value
		
		if littleEndian == isHostLittleEndian {
			try write(bytes: &x, length: 3)
		} else {
			x = value.byteSwapped
			x = x >> 8
			try write(bytes: &x, length: 3)
		}
	}
	
	
	func write(uint32 value: UInt32) throws {
		var x = littleEndian ? value.littleEndian : value.bigEndian
		try write(bytes: &x, length: 4)
	}
	
	
	func write(uint64 value: UInt64) throws {
		var x = littleEndian ? value.littleEndian : value.bigEndian
		try write(bytes: &x, length: 8)
	}
	
	
	func write(int8 value: Int8) throws {
		try write(uint8: UInt8(bitPattern: value))
	}
	
	
	func write(int16 value: Int16) throws {
		try write(uint16: UInt16(bitPattern: value))
	}
	
	
	func write(int24 value: Int32) throws {
		try write(uint24: UInt32(bitPattern: value))
	}
	
	
	func write(int32 value: Int32) throws {
		try write(uint32: UInt32(bitPattern: value))
	}
	
	
	func write(int64 value: Int64) throws {
		try write(uint64: UInt64(bitPattern: value))
	}
	
}




// MARK: - Types


protocol BinaryStreamDestination {
	var isEndOfStream: Bool { get }
	var length: Int { get }
	var position: Int { get }
	func setPosition(_ pos: Int) throws
	
	func read(bytes: UnsafeMutableRawPointer, length: Int) throws
}



protocol MutableBinaryStreamDestination: BinaryStreamDestination {
	func write(bytes: UnsafeRawPointer, length: Int) throws
}



enum BinaryStreamError: Error {
	/// Attempting to read or write data from outside the bounds of the data.
	case outOfBounds
	
	/// The destination is not resizable
	case notResizable
}







// MARK: - Destinations
extension BinaryStream {
	
	/// An NSData-backed destination which cannot be resized or written to
	class MemoryDestination: BinaryStreamDestination {
		
		fileprivate var _data: NSData
		
		
		init(data: NSData) {
			_data = data
		}
		
		
		/// Returns an immutable copy of the data.
		var data: NSData {
			return _data.copy() as! NSData
		}
		
		
		/// Returns whether the current position is at the end of the stream
		var isEndOfStream: Bool {
			return position == length
		}
		
		/// The length of the data in the stream.
		var length: Int {
			get {
				return _data.length
			}
		}
		
		
		/// The current position of the data in the stream. Reading and writing moves the position.
		fileprivate(set) var position: Int = 0
		
		
		/// Setting the position past the data length will throw 
		func setPosition(_ pos: Int) throws {
			if pos > length {
				throw BinaryStreamError.outOfBounds
			}
			position = pos
		}
		
		
		func read(bytes: UnsafeMutableRawPointer, length: Int) throws {
			guard _data.length >= position + length else {
				throw BinaryStreamError.outOfBounds
			}
			_data.getBytes(bytes, range: NSMakeRange(Int(position), Int(length)))
			position += length
		}
	}
	
	
	
	
	
	/// An NSData-backed destination which can be written to, an *may* be resizable if initialized to be so.
	class MutableMemoryDestination: MemoryDestination, MutableBinaryStreamDestination {
		
		private let resizable: Bool
		
		
		/// Initializes a writable, but not resizable, destination
		override init(data: NSData) {
			resizable = false
			super.init(data: data)
		}
		
		
		/// Initializes a writable and resizable, destination
		init(data: NSMutableData, resizable: Bool) {
			self.resizable = resizable
			super.init(data: data)
		}
		
		
		override var data: NSData {
			return _data
		}
		
		
		/// Returns the underlying mutable data of the destination.
		/// Be sure to correctly update the position of the destination
		/// if you modify the length of the mutable data to be shorter
		/// than the current position's value.
		var mutableData: NSMutableData {
			return _data as! NSMutableData
		}
		
		
		/// The length of the data in the stream.
		func setLength(_ length: Int) throws {
			guard resizable else {
				throw BinaryStreamError.notResizable
			}
			
			mutableData.length = Int(length)
		}
		
		
		/// Setting the position past the current length will grow the length of the stream. 
		override func setPosition(_ pos: Int) throws {
			if pos > length {
				guard resizable else {
					throw BinaryStreamError.notResizable
				}
				mutableData.increaseLength(by: Int(pos - length))
			}
			position = pos
		}
		
		
		func write(bytes: UnsafeRawPointer, length: Int) throws {
			if _data.length >= position + length {
				memcpy(UnsafeMutableRawPointer(mutating: _data.bytes.advanced(by: position)), bytes, Int(length))
			} else if resizable {
				let mdata = mutableData
				mdata.append(bytes, length: Int(length))
			} else {
				throw BinaryStreamError.notResizable
			}
			
			position += length
		}
	}
}






// MARK: - Stream Extensions

extension BinaryStream {
	func readUTF8String() throws -> String {
		let byteCount = Int(try readUInt32())
		if byteCount == 0 {
			return ""
		}
		
		let ptr = UnsafeMutableRawBufferPointer.allocate(count: Int(byteCount))
		try readBytes(ptr.baseAddress!, length: byteCount)
		
		guard let s = NSString(bytes: ptr.baseAddress!, length: Int(byteCount), encoding: String.Encoding.utf8.rawValue) else {
			return ""
		}
		
		return s as String
	}
}


extension MutableBinaryStream {
	func writeUTF8String(_ string: String) throws {
		try string.utf8CString.withUnsafeBufferPointer({ (ptr: UnsafeBufferPointer<CChar>) in
			precondition(ptr.count > 0, "Null-terminated utf8 buffer unexpectedly has count of 0")
			let byteCount = ptr.count - 1 // Discount null character
			try write(uint32: UInt32(byteCount))
			if byteCount > 0 {
				try write(bytes: ptr.baseAddress!, length: byteCount)
			}
		})
	}
}

