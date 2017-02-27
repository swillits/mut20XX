//
//  BinaryStream.swift
//  BinaryStream
//
//  Created by Seth Willits on 3/11/16.
//  Copyright © 2016 Araelium Group. All rights reserved.
//

import Foundation




class BinaryStream {
	
	private(set) var destination: BinaryStreamDestination
	
	init(destination: BinaryStreamDestination) {
		self.destination = destination
	}
	
	
	
	
	
	// MARK: - Properties
	
	private let isHostLittleEndian = (UInt32(littleEndian: 1) == 1)
	
	/// Determines whether the numeric types are written and read in big endian or little form. This can be changed at any time.
	var littleEndian: Bool = true
	
	
	/// Returns whether the current position is at the end of the stream
	var isEndOfStream: Bool {
		return destination.isEndOfStream
	}
	
	
	/// The length of the data in the stream.
	var length: UInt64 {
		get {
			return destination.length
		}
	}
	
	
	/// The current position of the data in the stream. Reading and writing moves the position.
	var position: UInt64 {
		get {
			return destination.position
		}
	}
	
	
	/// Depending on the stream type, setting the position past the length of the stream may:
	/// a) fail and throw (eg, when using file destination type)
	/// b) grow the length of the stream (eg, when using data destination type) 
	func setPosition(_ pos: UInt64) throws {
		try destination.setPosition(pos)
	}
	
	
	/// A simple convenience method for setPosition(position + offset)
	func offsetPosition(_ offset: Int64) throws {
		try setPosition(UInt64(Int64(position) + offset))
	}
	
	
	
	
	// MARK: - Writing
	
	func write(data: Data) throws {
		try destination.write(data)
	}
	
	
	func write(bytes: UnsafeRawPointer, length: UInt64) throws {
		try destination.write(bytes: bytes, length: length)
	}
	
	
	func write(float value: Float) throws {
		try write(float32: Float32(value))
	}
	
	
	func write(double value: Double) throws {
		try write(float64: Float64(value))
	}
	
	
	func write(float32 value: Float32) throws {
		var x = unsafeBitCast(value, to: UInt32.self)
		x = littleEndian ? x.littleEndian : x.bigEndian
		try write(bytes: &x, length: 4)
	}
	
	
	func write(float64 value: Float64) throws {
		var x = unsafeBitCast(value, to: UInt64.self)
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
		try write(uint8: unsafeBitCast(value, to: UInt8.self))
	}
	
	
	func write(int16 value: Int16) throws {
		try write(uint16: unsafeBitCast(value, to: UInt16.self))
	}
	
	
	func write(int24 value: Int32) throws {
		try write(uint24: unsafeBitCast(value, to: UInt32.self))
	}
	
	
	func write(int32 value: Int32) throws {
		try write(uint32: unsafeBitCast(value, to: UInt32.self))
	}
	
	
	func write(int64 value: Int64) throws {
		try write(uint64: unsafeBitCast(value, to: UInt64.self))
	}
	
	
	// MARK: - Reading
	
	func readBytes(_ bytes: UnsafeMutableRawPointer, length: UInt64) throws {
		try destination.read(bytes: bytes, length: length)
	}
	
	
	func readData(length: UInt64) throws -> Data {
		return try destination.readData(length: length)
	}
	
	
	func readBool() throws -> Bool {
		let b = try readUInt8()
		return b != 0
	}
	
	
	func readFloat() throws -> Float {
		var x: UInt32 = 0
		try destination.read(bytes: &x, length: 4)
		x = (littleEndian == isHostLittleEndian) ? x : x.byteSwapped
		return unsafeBitCast(x, to: Float.self)
	}
	
	
	func readDouble() throws -> Double {
		var x: UInt64 = 0
		try destination.read(bytes: &x, length: 8)
		x = (littleEndian == isHostLittleEndian) ? x : x.byteSwapped
		return unsafeBitCast(x, to: Double.self)
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
		return unsafeBitCast(try readUInt8(), to: Int8.self)
	}
	
	
	func readInt16() throws -> Int16 {
		return unsafeBitCast(try readUInt16(), to: Int16.self)
	}
	
	
	func readInt32() throws -> Int32 {
		return unsafeBitCast(try readUInt32(), to: Int32.self)
	}
	
	
	func readInt64() throws -> Int64 {
		return unsafeBitCast(try readUInt64(), to: Int64.self)
	}
}
	


	
// MARK: - Types


protocol BinaryStreamDestination {
	var isEndOfStream: Bool { get }
	var length: UInt64 { get }
	var position: UInt64 { get }
	func setPosition(_ pos: UInt64) throws
	
	func write(bytes: UnsafeRawPointer, length: UInt64) throws
	func read(bytes: UnsafeMutableRawPointer, length: UInt64) throws
	
	func write(_ data: Data) throws
	func readData(length: UInt64) throws -> Data
}



extension BinaryStream {
	enum BinaryStreamError: Error {
		/// Attempting to read data from outside the bounds of the data.
		case OutOfBounds
	}
}
	
	
	




// MARK: - Destinations
extension BinaryStream {
	
	/// An NSMutableData-backed destination which grows as needed when bytes are added at the end of the stream, or the position is set past the end of the stream.
	class DataDestination: BinaryStreamDestination {
		
		convenience init() {
			self.init(data: NSMutableData())
		}
		
		
		convenience init(data: NSData) {
			self.init(data: data.mutableCopy() as! NSMutableData)
		}
		
		
		init(data: NSMutableData) {
			_data = data
		}
		
		
		
		private var _data: NSMutableData
		
		
		/// Returns the underlying mutable data of the destination.
		/// Be sure to correctly update the position of the destination
		/// if you modify the length of the mutable data to be shorter
		/// than the current position's value.
		var mutableData: NSMutableData {
			return _data
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
		var length: UInt64 {
			get {
				return UInt64(_data.length)
			}
			set {
				_data.length = Int(newValue)
			}
		}
		
		
		/// The current position of the data in the stream. Reading and writing moves the position.
		private(set) var position: UInt64 = 0
		
		
		/// Setting the position past the current length will grow the length of the stream. In this 
		func setPosition(_ pos: UInt64) throws {
			if pos > length {
				_data.increaseLength(by: Int(pos - length))
			}
			position = pos
		}
		
		
		func write(bytes: UnsafeRawPointer, length: UInt64) {
			if UInt64(_data.length) >= position + length {
				memcpy(_data.mutableBytes, bytes, Int(length))
			} else {
				_data.append(bytes, length: Int(length))
			}
			
			position += length
		}
		
		
		func read(bytes: UnsafeMutableRawPointer, length: UInt64) throws {
			guard UInt64(_data.length) >= position + length else {
				throw BinaryStreamError.OutOfBounds
			}
			_data.getBytes(bytes, range: NSMakeRange(Int(position), Int(length)))
			position += length
		}
		
		
		
		func write(_ data: Data) {
			data.withUnsafeBytes { (ptr: UnsafePointer) in
				write(bytes: ptr, length: UInt64(data.count))
			}
		}
		
		
		func readData(length: UInt64) throws -> Data {
			guard UInt64(_data.length) >= position + length else {
				throw BinaryStreamError.OutOfBounds
			}
			let data = _data.subdata(with: NSMakeRange(Int(position), Int(length)))
			position += length
			return data
		}
	}
}


/*
extension BinaryStream {
	
	class FileDestination: BinaryStreamDestination {
	
	struct Options: OptionSetType {
	let rawValue: Int
	
	static let Read				= Options(rawValue: 1 << 1)
	static let Write			= Options(rawValue: 1 << 2)
	static let LittleEndian		= Options(rawValue: 1 << 3)
	static let BigEndian		= Options(rawValue: 1 << 4)
	static let Default			= Read
	static let DefaultL			= [Read, LittleEndian]
	static let DefaultB			= [Read, BigEndian]
	}
	
	var data: NSMutableData
	
	init() {
	data = NSMutableData()
	}
	
	init(data: NSMutableData) {
	self.data = data
	}
	
	
	
	
	func open(options: Options) throws {
	
	}
	
	
	func close() {
	
	}
	
	
	func flush() {
	
	}
	
	
	
	
	func writeBytes(bytes: UnsafePointer<Void>, length: UInt64) {
	data.appendBytes(bytes, length: Int(length))
	}
	
	
	func readBytes(_ bytes: UnsafePointer<Void>, length: UInt64) throws {
	
	}
	}
}*/








// MARK: - Stream Extensions

extension BinaryStream {
	
	func writeUTF8String(_ string: String) throws {
		try string.utf8CString.withUnsafeBufferPointer({ (ptr: UnsafeBufferPointer<CChar>) in
			precondition(ptr.count > 0, "Null-terminated utf8 buffer unexpectedly has count of 0")
			let byteCount = ptr.count - 1 // Discount null character
			try write(uint32: UInt32(byteCount))
			if byteCount > 0 {
				try write(bytes: ptr.baseAddress!, length: UInt64(byteCount))
			}
		})
	}
	
	
	func readUTF8String() throws -> String {
		let byteCount = try readUInt32()
		if byteCount == 0 {
			return ""
		}
		
		let ptr = UnsafeMutableRawBufferPointer.allocate(count: Int(byteCount))
		try readBytes(ptr.baseAddress!, length: UInt64(byteCount))
		
		guard let s = NSString(bytes: ptr.baseAddress!, length: Int(byteCount), encoding: String.Encoding.utf8.rawValue) else {
			return ""
		}
		
		return s as String
	}
	
	
	// Writing convenience
	//
	//	func write(int8   value: Int) throws { try write(uint8:  unsafeBitCast(Int8(value),  UInt8.self))  }
	//	func write(int16  value: Int) throws { try write(uint16: unsafeBitCast(Int16(value), UInt16.self)) }
	//	func write(int32  value: Int) throws { try write(uint32: unsafeBitCast(Int32(value), UInt32.self)) }
	//	func write(int64  value: Int) throws { try write(uint64: unsafeBitCast(Int64(value), UInt64.self)) }
	//	
	//	func write(uint8  value: Int) throws { try write(uint8:  unsafeBitCast(Int8(value),  UInt8.self))  }
	//	func write(uint16 value: Int) throws { try write(uint16: unsafeBitCast(Int16(value), UInt16.self)) }
	//	func write(uint32 value: Int) throws { try write(uint32: unsafeBitCast(Int32(value), UInt32.self)) }
	//	func write(uint64 value: Int) throws { try write(uint64: unsafeBitCast(Int64(value), UInt64.self)) }
	//	
	//	func write(uint8  value: UInt) throws { try write(uint8:  UInt8(value)) }
	//	func write(uint16 value: UInt) throws { try write(uint16: UInt16(value)) }
	//	func write(uint32 value: UInt) throws { try write(uint32: UInt32(value)) }
	//	func write(uint64 value: UInt) throws { try write(uint64: UInt64(value)) }
	
	//	func write(value: UInt8)  throws { try write(uint8:  value) }
	//	func write(value: UInt16) throws { try write(uint16: value) }
	//	func write(value: UInt32) throws { try write(uint32: value) }
	//	func write(value: UInt64) throws { try write(uint64: value) }
	//	
	//	func write(value: Int8)  throws { try write(int8:  value) }
	//	func write(value: Int16) throws { try write(int16: value) }
	//	func write(value: Int32) throws { try write(int32: value) }
	//	func write(value: Int64) throws { try write(int64: value) }
}

