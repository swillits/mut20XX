//
//  NetMessage.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation


class NetMessage {
	
	// MARK: - Message Types
	
	enum MsgType: Int {
		case generic
		case playerConnection
		case general
		case lobby
		case game
		case clientMessage
	}
	
	
	enum PlayerConnectionSubtype: Int {
		case request
		case granted
		case denied
	}
	
	enum GeneralSubtype: Int {
		case playersInfo
	}
	
	enum LobbySubtype: Int {
		case changedReady
		//hostRequestsStart// host client -> server
	}
	
	enum MsgSubtype: Int {
		case prepare
		case isPrepared
		case start
		
		case gameOver
		case playerDied
		case shapes
		case embedShape
		case completedRows
		case transferRows
		
		case returnToLobby
	}
	
	
	// =================================================================================
	// MARK: -
	
	private var isWritable: Bool
	
	private let dd: BinaryStream.DataDestination
	private let bs: BinaryStream
	
	var type: MsgType
	var subtype: MsgSubtype
	
	
	init(type: MsgType, subtype: MsgSubtype) {
		self.type = type
		self.subtype = subtype
		
		isWritable = true
		dd = BinaryStream.DataDestination()
		bs = BinaryStream(destination: dd)
		bs.littleEndian = true
		
		write(int16: Int16(type.rawValue))
		write(int16: Int16(subtype.rawValue))
	}
	
	
	init(data: Data) {
		isWritable = false
		dd = BinaryStream.DataDestination(data: data as NSData)
		bs = BinaryStream(destination: dd)
		bs.littleEndian = true
		
		type = NetMessage.MsgType(rawValue: Int(try! bs.readInt16()))!
		subtype = NetMessage.MsgSubtype(rawValue: Int(try! bs.readInt16()))!
	}
	
	
	
	
	// MARK: - Writing
	
	func write(data: Data) {
		precondition(isWritable)
		try! bs.write(data: data)
	}
	
	
	func write(float32 value: Float32) {
		precondition(isWritable)
		try! bs.write(float32: value)
	}
	
	
	func write(float64 value: Float64) {
		precondition(isWritable)
		try! bs.write(float64: value)
	}
	
	
	func write(bool value: Bool) {
		precondition(isWritable)
		try! bs.write(bool: value)
	}
	
	
	func write(uint8 value: UInt8) {
		precondition(isWritable)
		try! bs.write(uint8: value)
	}
	
	
	func write(uint16 value: UInt16) {
		precondition(isWritable)
		try! bs.write(uint16: value)
	}
	
	
	func write(uint24 value: UInt32) {
		precondition(isWritable)
		try! bs.write(uint24: value)
	}
	
	
	func write(uint32 value: UInt32) {
		precondition(isWritable)
		try! bs.write(uint32: value)
	}
	
	
	func write(uint64 value: UInt64) {
		precondition(isWritable)
		try! bs.write(uint64: value)
	}
	
	
	func write(int8 value: Int8) {
		precondition(isWritable)
		try! bs.write(int8: value)
	}
	
	
	func write(int16 value: Int16) {
		precondition(isWritable)
		try! bs.write(int16: value)
	}
	
	
	func write(int24 value: Int32) {
		precondition(isWritable)
		try! bs.write(int24: value)
	}
	
	
	func write(int32 value: Int32) {
		precondition(isWritable)
		try! bs.write(int32: value)
	}
	
	
	func write(int64 value: Int64) {
		precondition(isWritable)
		try! bs.write(int64: value)
	}
	
	
	
	// MARK: - Reading
	
	func readData(length: UInt64) -> Data {
		precondition(!isWritable)
		return try! bs.readData(length: length)
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
}


