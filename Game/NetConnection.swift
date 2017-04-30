//
//  NetConnection.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation




@objc protocol NetConnectionDelegate {
	
	// Required for listening sockets
	// ----------------------------------
	@objc optional func connection(_ connection: NetConnection, didAcceptNewConnection newConnection: NetConnection)
	
	// Required for connection sockets
	// ----------------------------------
	@objc optional func connectionDidConnect(_ connection: NetConnection)
	
	// Required for all sockets(?)
	// ----------------------------------
	@objc optional func connectionDidDisconnect(_ connection: NetConnection, error: Error?)
}




class NetConnection: NSObject, GCDAsyncSocketDelegate {
	
	var delegate: NetConnectionDelegate? = nil
	private var socket: GCDAsyncSocket
	private var readBuffer = NSMutableData()
	private var packets: [NetPacket] = []
	
	
	override init() {
		socket = GCDAsyncSocket()
		super.init()
		socket.delegate = self
	}
	
	
	init(socket: GCDAsyncSocket) {
		self.socket = socket
		super.init()
		socket.delegate = self
	}
	
	
	override var description: String {
		return "<NetConnection {\(String(describing: socket.connectedHost)):\(socket.connectedPort)}>"
	}
	
	
	
	
	// MARK: - Connecting
	
	/// Connects in the background, delegate methods are for success/failure
	func connect(host: String, port: UInt16, timeout: TimeInterval) throws {
		precondition(!socket.isConnected)
		socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
		try socket.connect(toHost: host, onPort: port, withTimeout: timeout)
	}
	
	
	func accept(onPort port: UInt16) throws {
		precondition(!socket.isConnected)
		socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
		try socket.accept(onPort: port)
	}
	
	
	func disconnectAfterWriting() {
		socket.delegate = nil
		socket.disconnectAfterWriting()
	}
	
	
	
	// MARK: - Status
	
	var isConnected: Bool {
		return socket.isConnected
	}
	
	var connectedHost: String? {
		return socket.connectedHost
	}
	
	var connectedPort: UInt16 {
		return socket.connectedPort
	}
	
	var localHost: String? {
		return socket.localHost
	}
	
	var localPort: UInt16 {
		return socket.localPort
	}
	
	
	
	
	// MARK: - Reading
	
	func queueRead() {
		socket.readData(withTimeout:-1, tag:0)
	}
	
	
	var packetCount: Int {
		return packets.count
	}
	
	
	func popPackets() -> [NetPacket] {
		let packets: [NetPacket] = self.packets
		self.packets = []
		return packets
	}
	
	
	
	
	// MARK: - Writing
	
	func write(_ packet: NetPacket) {
		socket.write(headerData(for: packet), withTimeout:-1, tag:0)
		socket.write(packet.payload, withTimeout:-1, tag:0)
	}






	// MARK - Socket Delegate
	
	internal func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
		let newConnection = NetConnection(socket: newSocket)
		delegate?.connection?(self, didAcceptNewConnection: newConnection)
	}
	
	
	internal func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
		delegate?.connectionDidConnect?(self)
	}
	
	
	internal func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
		delegate?.connectionDidDisconnect?(self, error: err)
	}
	
	
	internal func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
		return 0.0
	}
	
	
	internal func socket(_ sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
		return 0.0
	}
	
	
	internal func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
		readBuffer.append(data)
		findPackets()
	}
	
	
	
	// MARK: - Packets
	private let NetPacketMagic: UInt32 = 0xDEADBEEF // need to ensure this const is in little endian form
	private let NetPacketHeaderSize = 12 
	
	private func headerData(for packet: NetPacket) -> Data {
		let dd = BinaryStream.MutableMemoryDestination(data: NSMutableData(), resizable: true)
		let bs = MutableBinaryStream(destination: dd)
		bs.littleEndian = true
		
		try! bs.write(uint32: NetPacketMagic)
		try! bs.write(uint32: UInt32(packet.number))
		try! bs.write(uint16: UInt16(0)) // reserved
		try! bs.write(uint16: UInt16(packet.payload.count))
		return dd.data as Data
	}
	
	
	private func findPackets() {
		
		// The read buffer's bytes *always* begin with the beginning of a packet,
		// but it can contain one or more partial or complete packets, so find em
		// 
		// <check the 'magic' header field to verify this actually a packet, otherwise
		//  we need to skip until we find 'magic' ??>
		
		let dd = BinaryStream.MemoryDestination(data: readBuffer as NSData)
		let bs = BinaryStream(destination: dd)
		
		let readBufferLength = readBuffer.length
		var emptyBefore = 0
		
		while bs.position < bs.length {
			
			// Stop if we can't read a packet header
			if Int(bs.position) + NetPacketHeaderSize > readBufferLength {
				break
			}
			
			// Read the header
			let magic          : UInt32 = try! bs.readUInt32()
			let packetNumber   : UInt32 = try! bs.readUInt32()
			let _ /*reserved*/ : UInt16 = try! bs.readUInt16()
			let payloadSize    : UInt16 = try! bs.readUInt16()
			precondition(magic == NetPacketMagic, "No recovery for transmission data loss")
			
			// Stop if we can't read the payload
			if Int(bs.position) + Int(payloadSize) > readBufferLength {
				break
			}
			
			// Read the packet
			let payload = try! bs.readData(length: Int(payloadSize))
			let packet = NetPacket(number: Int(packetNumber), payload: payload) 
			foundPacket(packet)
			
			// Have read the header and payload
			emptyBefore = Int(bs.position)
		}
		
		
		// Chop off the part of the buffer that we've already read
		if emptyBefore > 0 {
			readBuffer.replaceBytes(in: NSMakeRange(0, emptyBefore), withBytes: nil, length: 0)
		}
	}
	
	
	
	private func foundPacket(_ packet: NetPacket) {
		
		// Put the packets in ascending order of packet number
		if let index = packets.index(where: { $0.number > packet.number }) {
			packets.insert(packet, at: index)
		} else {
			packets.append(packet)
		}
	}
}





struct NetPacket {
	let number: Int
	var payload: Data
	
	var description: String {
		return "<NetPacket {N:\(number), \(payload.count) bytes}>"
	}
}



