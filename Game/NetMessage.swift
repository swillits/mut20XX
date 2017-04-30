//
//  NetMessage.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation


class NetMessage {
	
	// MARK: - Message Types
	
	struct MsgType {
		static let playerConnection = 1
		static let general = 2
		static let lobby = 3
		static let game = 4
//		static let clientMessage = 4
//		static let generic = 5
	}
	
	
	struct PlayerConnectionSubtype {
		static let request = 1
		static let granted = 2
		static let denied  = 3
	}
	
	struct GeneralSubtype {
		static let playersInfo = 1
	}
	
	struct LobbySubtype {
		static let changedReady = 1
		//hostRequestsStart// host client -> server
	}
	
	struct GameSubtype {
		static let prepare = 1
		static let isPrepared = 2
		static let start = 3
		
		static let gameOver = 4
		static let playerDied = 5
		static let shapes = 6
		static let embedShape = 7
		static let completedRows = 8 
		static let transferRows = 9
		
		static let returnToLobby = 10
	}
	
	
	enum DropReason: Int {
		case serverIsFull = 1
		case serverShuttingDown = 2
		case gameInProgress = 3
		case clientLost = 4
		case playerNameNotUnique = 5
		case playerNameInvalid = 6
	}
	
	
	// =================================================================================
	// MARK: -
	
	private var isWritable: Bool
	
	private let _data: NSMutableData
	private let dd: BinaryStream.MutableMemoryDestination
	private let bs: BinaryStream!
	private let mbs: MutableBinaryStream!
	
	var type: Int
	var subtype: Int
	
	
	init(type: Int, subtype: Int) {
		self.type = type
		self.subtype = subtype
		
		isWritable = true
		_data = NSMutableData()
		dd = BinaryStream.MutableMemoryDestination(data: _data, resizable: true)
		mbs = MutableBinaryStream(destination: dd)
		mbs.littleEndian = true
		bs = mbs
		
		write(int16: Int16(type))
		write(int16: Int16(subtype))
	}
	
	
	init(data: Data) {
		isWritable = false
		_data = NSMutableData(data: data)
		dd = BinaryStream.MutableMemoryDestination(data: _data, resizable: false)
		bs = BinaryStream(destination: dd)
		bs.littleEndian = true
		mbs = nil
		
		type = Int(try! bs.readInt16())
		subtype = Int(try! bs.readInt16())
	}
	
	
	
	
	// MARK: - Writing
	
	func data() -> Data {
		return _data as Data
	}
	
	
	func write(data: Data) {
		precondition(isWritable)
		try! mbs.write(data: data)
	}
	
	
	func write(float32 value: Float32) {
		precondition(isWritable)
		try! mbs.write(float32: value)
	}
	
	
	func write(float64 value: Float64) {
		precondition(isWritable)
		try! mbs.write(float64: value)
	}
	
	
	func write(bool value: Bool) {
		precondition(isWritable)
		try! mbs.write(bool: value)
	}
	
	
	func write(uint8 value: UInt8) {
		precondition(isWritable)
		try! mbs.write(uint8: value)
	}
	
	
	func write(uint16 value: UInt16) {
		precondition(isWritable)
		try! mbs.write(uint16: value)
	}
	
	
	func write(uint24 value: UInt32) {
		precondition(isWritable)
		try! mbs.write(uint24: value)
	}
	
	
	func write(uint32 value: UInt32) {
		precondition(isWritable)
		try! mbs.write(uint32: value)
	}
	
	
	func write(uint64 value: UInt64) {
		precondition(isWritable)
		try! mbs.write(uint64: value)
	}
	
	
	func write(int8 value: Int8) {
		precondition(isWritable)
		try! mbs.write(int8: value)
	}
	
	
	func write(int16 value: Int16) {
		precondition(isWritable)
		try! mbs.write(int16: value)
	}
	
	
	func write(int24 value: Int32) {
		precondition(isWritable)
		try! mbs.write(int24: value)
	}
	
	
	func write(int32 value: Int32) {
		precondition(isWritable)
		try! mbs.write(int32: value)
	}
	
	
	func write(int64 value: Int64) {
		precondition(isWritable)
		try! mbs.write(int64: value)
	}
	
	
	func write(string: String) {
		precondition(isWritable)
		try! mbs.writeUTF8String(string)
	}
	
	
	
	// MARK: - Reading
	
	func readData(length: UInt64) -> Data {
		precondition(!isWritable)
		return try! bs.readData(length: Int(length))
	}
	
	
	func readBool() -> Bool {
		precondition(!isWritable)
		return try! bs.readBool()
	}
	
	
	func readFloat32() -> Float32 {
		precondition(!isWritable)
		return try! bs.readFloat32()
	}
	
	
	func readFloat64() -> Float64 {
		precondition(!isWritable)
		return try! bs.readFloat64()
	}
	
	
	func readUInt8() -> UInt8 {
		precondition(!isWritable)
		return try! bs.readUInt8()
	}
	
	
	func readUInt16() -> UInt16 {
		precondition(!isWritable)
		return try! bs.readUInt16()
	}
	
	
	func readUInt24() -> UInt32 {
		precondition(!isWritable)
		return try! bs.readUInt24()
	}
	
	
	func readUInt32() -> UInt32 {
		precondition(!isWritable)
		return try! bs.readUInt32()
	}
	
	
	func readUInt64() -> UInt64 {
		precondition(!isWritable)
		return try! bs.readUInt64()
	}
	
	
	func readInt8() -> Int8 {
		precondition(!isWritable)
		return try! bs.readInt8()
	}
	
	
	func readInt16() -> Int16 {
		precondition(!isWritable)
		return try! bs.readInt16()
	}
	
	
	func readInt32() -> Int32 {
		precondition(!isWritable)
		return try! bs.readInt32()
	}
	
	
	func readInt64() -> Int64 {
		precondition(!isWritable)
		return try! bs.readInt64()
	}
	
	
	func readString() -> String {
		precondition(!isWritable)
		return try! bs.readUTF8String()
	}
}


