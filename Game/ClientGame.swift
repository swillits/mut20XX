//
//  ClientGame.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation


/// Persistent object across games, on the client
class ClientGame: NetConnectionDelegate {
	private var shapeGenerator = Piece.Shape.Generator()
	let inputMap = PlayerInputMap()
	var state = GameState()
	
	
	init() {
		// TODO: Connect to prefs and UI
		inputMap.setTriggers([.keycode(Keycode.space)],      for: .drop)
		inputMap.setTriggers([.keycode(Keycode.downArrow)],  for: .moveDown)
		inputMap.setTriggers([.keycode(Keycode.leftArrow)],  for: .moveLeft)
		inputMap.setTriggers([.keycode(Keycode.rightArrow)], for: .moveRight)
		inputMap.setTriggers([.keycode(Keycode.a)],          for: .rotateLeft)
		inputMap.setTriggers([.keycode(Keycode.d)],          for: .rotateRight)
		
		state.localPlayer.clientID = 0
		state.localPlayer.name = "Local Player"
		state.localPlayer.score = 0
		state.localPlayer.isAlive = true
		state.localPlayer.isReady = true
		state.localPlayer.gameIsPrepared = true
		
		advanceLocalPlayerPiece()
		advanceLocalPlayerPiece()
	}
	
	
	
	
	// MARK: - Connection to Server
	
	fileprivate let connection = NetConnection()
	fileprivate var clientStatus: ClientStatus = .uninitialized
	fileprivate var connectedAtTime: TimeInterval = 0.0
	fileprivate var lastPacketAtTime: TimeInterval = 0.0
	fileprivate var connectHandler: ((Error?) -> ())? = nil
	
	enum ClientStatus {
		case uninitialized
		case disconnected       // not talking to a server
		case connected			// socket connected but the player is not yet accepted 
		case joined				// player is now connected, nothing more
		case loading			// -- only during cgame initialization, never during main loop --
		case primed				// got gamestate, waiting for first frame
		case active				// game views should be displayed 
	}
	
	
	func connect(to serverAddress: String, port: UInt16, playerName: String, handler: (Error?) -> ()) {
		connection.delegate = self
		try! connection.connect(host: serverAddress, port: port, timeout: 10.0)
	}
	
	
	func disconnect(reason: NetMessage.DropReason) {
		clientStatus = .disconnected
		
		connection.disconnectAfterWriting()
		connection.delegate = nil
		
		// TODO ... go back to previous scene
		// display reasonToDisplay
		// [[GBSceneManager sharedManager] popScene // ??
	}

	
	
	func connectionDidConnect(_ connection: NetConnection) {
		print("[Client] did connect")
		
		if let handler = connectHandler {
			handler(nil)
			connectHandler = nil
		}
		
		connectedAtTime = Date.timeIntervalSinceReferenceDate
		lastPacketAtTime = connectedAtTime
		clientStatus = .connected
		send(messageAfterConnecting())
	}
	
	
	func connectionDidDisconnect(_ connection: NetConnection, error: Error?) {
		if let error = error {
			print("[Client] Disconnected from server because of error %@", error)
		} else {
			print("[Client] Disconnected from server")
		}
		
		clientStatus = .disconnected
		
		if let handler = connectHandler {
			handler(error)
			connectHandler = nil
		}
	}
	
	
	
	
	
	
	// --------------
	
	func start() {
		state.phase = .playing
	}
	
	
	
	func update(timing: UpdateTiming) {
		
		// Check for messages from server
		connection.queueRead()
		if connection.packetCount > 0 {
			lastPacketAtTime = timing.now
			process(packets: connection.popPackets())
		}
		
		switch state.phase {
		case .prepping:
			
			// TODO: Move to prepped, tell the server, wait for the server to tell us to move into .playing
			// state.phase = .prepped
			// < tell server >
			
			// For now with single player:
			state.phase = .playing
			
		case .prepped, .gameOver, .watching:
			return
			
		case .playing:
			updateLocalPlayer(timing: timing)
			inputMap.clearActivated()
		}
	}
	
	
	
	private func updateLocalPlayer(timing: UpdateTiming) {
		guard state.localPlayer.isAlive else {
			return
		}
		
		if let action = inputMap.rotatingAction() {
			actOnFallingPiece(input: action, timing: timing)
		}
		
		if let action = inputMap.horizontalMoveAction() {
			actOnFallingPiece(input: action, timing: timing)
		}
		
		if inputMap[.moveDown].activated || inputMap[.moveDown].active {
			actOnFallingPiece(input: .moveDown, timing: timing)
		}
		
		if inputMap[.drop].activated {
			actOnFallingPiece(input: .drop, timing: timing)
		}
		
		updateFallingPiece(timing: timing)
		checkForCompletedLines()
	}
	
	
	
	private func updateFallingPiece(timing: UpdateTiming) {
		guard timing.now - state.lastFallingTime >= Game.normalTimeBetweenFalls else {
			return
		}
		
		let piece = state.localPlayer.currentPiece.proposed(by: .moveDown)
		if state.localPlayer.board.doesPositionCollide(piece: piece) {
			actOnFallingPiece(input: .drop, timing: timing)
		} else {
			state.localPlayer.currentPiece = piece
			state.lastFallingTime = timing.now
			// TODO: tell server
		}
	}
	
	
	
	private func checkForCompletedLines() {
		let linesRemoved = state.localPlayer.board.removeCompletedLines()
		if !linesRemoved.isEmpty {
			if linesRemoved.count == 0 {
				GameSound.completeFourLines.play()
			} else if linesRemoved.count > 0 {
				GameSound.completeLine.play()
			}
			
			// TODO: score update, tell server
			send(messageForCompletedLines(linesRemoved))
		}
	}
	
	
	
	private func actOnFallingPiece(input: PlayerInput, timing: UpdateTiming) {		
		switch input {
		case .moveLeft, .moveRight, .moveDown, .rotateLeft, .rotateRight:
			if timingAllowsAction(input: input, timing: timing) {
				let piece = state.localPlayer.currentPiece.proposed(by: input)
				if !state.localPlayer.board.doesPositionCollide(piece: piece) {
					playSound(for: input)
					state.localPlayer.currentPiece = piece
					updateTimingForAction(input: input, timing: timing)
					// TODO: tell server
				}	
			}
			
			// TODO: Rotation needs to...
			//	- Is it not a valid move?
			//		- Try moving one once to the right. If valid, move temp piece location.
			//	- Otherwise, try left one.
			//	- Next try two right, then two left.

			
		case .drop:
			var piece = state.localPlayer.currentPiece
			piece.position = state.localPlayer.board.finalPositionIfDropped(piece: state.localPlayer.currentPiece)
			advanceLocalPlayerPiece()
			state.lastFallingTime = timing.now
			// TODO: tell server
			
			
			if state.localPlayer.board.doesPieceSpillOverTop(piece: piece) {
				GameSound.collision.play()
				state.localPlayer.isAlive = false
			} else {
				GameSound.dropBlock.play()
			}
			
			state.localPlayer.board.perform(action: .placePiece(piece))
		}
	}
		
		
		
	private func timingAllowsAction(input: PlayerInput, timing: UpdateTiming) -> Bool {
		switch input {
		case .moveLeft, .moveRight:
			return timing.now - state.lastHorizontalMovementTime >= Game.minimumTimeBetweenHorizontalMoves
		case .moveDown:
			return timing.now - state.lastVerticalMovementTime >= Game.minimumTimeBetweenVerticalMoves
		case .rotateLeft, .rotateRight:
			return timing.now - state.lastRotationTime >= Game.minimumTimeBetweenRotations
		default:
			return true
		}
	}
	
	
	
	private func updateTimingForAction(input: PlayerInput, timing: UpdateTiming) {
		switch input {
		case .moveLeft, .moveRight:
			state.lastHorizontalMovementTime = timing.now
		case .moveDown:
			state.lastVerticalMovementTime = timing.now
		case .rotateLeft, .rotateRight:
			state.lastRotationTime = timing.now
		case .drop:
			state.lastFallingTime = timing.now
			state.lastVerticalMovementTime = timing.now - Game.minimumTimeBetweenVerticalMoves
		}
	}
	
	
	
	private func playSound(for input: PlayerInput) {
		switch input {
		case .moveLeft, .moveRight:
			GameSound.moveBlock.play()
		case .moveDown:
			return
		case .rotateLeft, .rotateRight:
			GameSound.moveBlock.play()
		case .drop:
			GameSound.dropBlock.play()
		}
	}
	
	
	
	private func advanceLocalPlayerPiece() {
		state.localPlayer.currentPiece = state.localPlayer.nextPiece
		state.localPlayer.nextPiece = Piece(shape: shapeGenerator.nextShape(), position: Board.initialPiecePosition, rotation: .north)
	}
}




extension ClientGame {
	struct UpdateTiming {
		
		/// Absolute time of the frame
		let now: TimeInterval
		
		/// Delta since previous update
		let delta: TimeInterval
	}
}





extension ClientGame {
	
	fileprivate func player(clientID: Int) -> Player? {
		if clientID == state.localPlayer.clientID {
			return state.localPlayer
		}
		
		return opponent(clientID: clientID)
	}


	fileprivate func opponent(clientID: Int) -> Player? {
		for player in state.players {
			if player.clientID == clientID {
				return player
			}
		}
		
		return nil
	}
	
	
	
	// MARK: - Outgoing
	
	fileprivate func send(_ message: NetMessage) {
		connection.write(NetPacket(number: 0, payload: message.data()))
	}
	
	
	fileprivate func messageAfterConnecting() -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.playerConnection, subtype: NetMessage.PlayerConnectionSubtype.request)
		msg.write(string: state.localPlayer.name)
		return msg
	}



	fileprivate func messageForLobbyReady() -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.lobby, subtype: NetMessage.LobbySubtype.changedReady)
		msg.write(bool: state.localPlayer.isReady)
		return msg
	}



	fileprivate func messageForGameIsPrepared() -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.game, subtype: NetMessage.GameSubtype.isPrepared)
		return msg
	}



	fileprivate func messageForShapes() -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.game, subtype: NetMessage.GameSubtype.shapes)
		msg.write(uint32: UInt32(state.localPlayer.clientID))
		msg.write(uint32: UInt32(state.localPlayer.currentPiece.shape.rawValue))
		msg.write(uint32: UInt32(state.localPlayer.currentPiece.position.x))
		msg.write(uint32: UInt32(state.localPlayer.currentPiece.position.y))
		msg.write(uint32: UInt32(state.localPlayer.currentPiece.rotation.rawValue))
		msg.write(uint32: UInt32(state.localPlayer.nextPiece.shape.rawValue))
		return msg
	}



	fileprivate func messageForEmbedShape() -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.game, subtype: NetMessage.GameSubtype.embedShape)
		msg.write(uint32: UInt32(state.localPlayer.clientID))
		msg.write(uint32: UInt32(state.localPlayer.currentPiece.shape.rawValue))
		msg.write(uint32: UInt32(state.localPlayer.currentPiece.position.x))
		msg.write(uint32: UInt32(state.localPlayer.currentPiece.position.y))
		msg.write(uint32: UInt32(state.localPlayer.currentPiece.rotation.rawValue))
		
		return msg
	}



	fileprivate func messageForCompletedLines(_ lines: IndexSet) -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.game, subtype: NetMessage.GameSubtype.completedRows)
	
		msg.write(uint32: UInt32(state.localPlayer.clientID))
		msg.write(uint32: UInt32(lines.count))
		
		for index in lines {
			msg.write(uint32: UInt32(index))
		}
		
		return msg
	}



	fileprivate func messageForPlayerDied() -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.game, subtype: NetMessage.GameSubtype.playerDied)
		msg.write(uint32: UInt32(state.localPlayer.clientID))
		return msg
	}
	
	
	// MARK: - Incoming Packets

	fileprivate func process(packets: [NetPacket]) {
		for packet in packets {
			//print("[Client] Received packet: %@", packet)
			let msg = NetMessage(data: packet.payload)
			
			switch (msg.type, msg.subtype) {
			case (NetMessage.MsgType.playerConnection, _):
				handle_playerConnectionResult(msg)
				
			case (NetMessage.MsgType.general, NetMessage.GeneralSubtype.playersInfo):
				handle_playersInfo(msg)
			
			case (NetMessage.MsgType.lobby, NetMessage.LobbySubtype.changedReady):
				handle_lobbyChangedReady(msg)
			
			case (NetMessage.MsgType.game, _):
				switch msg.subtype {
				case NetMessage.GameSubtype.prepare:
					handle_gamePrepare(msg)
					
				case NetMessage.GameSubtype.start:
					handle_gameStart(msg)
				
				case NetMessage.GameSubtype.shapes:
					handle_gameShapes(msg)
				
				case NetMessage.GameSubtype.embedShape:
					handle_gameEmbedShape(msg)
				
				case NetMessage.GameSubtype.completedRows:
					handle_gameCompletedRows(msg)
				
				case NetMessage.GameSubtype.playerDied:
					handle_gamePlayerDied(msg)
				
				case NetMessage.GameSubtype.gameOver:
					handle_gameOver(msg)
				
				case NetMessage.GameSubtype.returnToLobby:
					handle_returnToLobby(msg)
				
				default: break
				}
			default: break
			}
		}
	}
	
	
	
	fileprivate func handle_playerConnectionResult(_ msg: NetMessage) {
		if msg.subtype == NetMessage.PlayerConnectionSubtype.granted {
			state.localPlayer.clientID = Int(msg.readUInt32())
			clientStatus = .connected
			// (Will receive more info from server soon.)
			
		} else if msg.subtype == NetMessage.PlayerConnectionSubtype.denied {
			let reasonInt = Int(msg.readInt8())
			let reason = NetMessage.DropReason(rawValue: reasonInt)!
			
			print("[Client] Player connection denied. \(reason)")
			disconnect(reason: reason)
		}
	}
	
	
	
	fileprivate func handle_playersInfo(_ msg: NetMessage) {
		
		// Create or update Opponents (and self)
		var newOpponents: [Player] = []
		
		let numPlayers = msg.readUInt32()
		
		for _ in 0 ..< numPlayers {
			let clientID = Int(msg.readUInt32())
			let name = msg.readString()
			let isReady = msg.readBool()
			let isAlive = msg.readBool()
			
			if clientID == state.localPlayer.clientID {
				
				// In the current architecture, we ignore this info because
				// we are the authoritative source of this info, not the server,
				// and it may have already changed since we sent it last.
				// -- 
				// Except when the server tells us to go back to the lobby,
				// it also resets everyone to not being ready, so we should
				// use that info, so for now we are going to use it...
				
				state.localPlayer.isReady = isReady
				state.localPlayer.isAlive = isAlive
				
			} else {
				var op = opponent(clientID: clientID)
				if op == nil {
					op = Player(name: name, clientID: clientID)
				}
				
				op!.clientID = clientID
				op!.name = name
				op!.isReady = isReady
				op!.isAlive = isAlive
				
				newOpponents.append(op!)
			}
		}
		
		// Update opponents list
		state.players = newOpponents
	}



	fileprivate func handle_lobbyChangedReady(_ msg: NetMessage) {
		let clientID = Int(msg.readUInt32())
		let isReady = msg.readBool()
		
		if let op = opponent(clientID: clientID) {
			op.isReady = isReady
		}
	}



	fileprivate func handle_gamePrepare(_ msg: NetMessage) {
		// TODO: push game scene
		send(messageForGameIsPrepared())
	}



	fileprivate func handle_gameStart(_ msg: NetMessage) {
		startGame()
	}



	fileprivate func handle_gameShapes(_ msg: NetMessage) {
		let clientID  = Int(msg.readUInt32())
		let shape     = Piece.Shape(rawValue: Int(msg.readUInt32()))!
		let x         = Int(msg.readUInt32())
		let y         = Int(msg.readUInt32())
		let rotation  = Rotation(rawValue: Int(msg.readUInt32()))!
		let nextShape = Piece.Shape(rawValue: Int(msg.readUInt32()))!
		
		let op = opponent(clientID: clientID)!
		op.currentPiece.shape = shape
		op.currentPiece.position.x = x
		op.currentPiece.position.y = y
		op.currentPiece.rotation = rotation
		op.nextPiece.shape = nextShape
	}



	fileprivate func handle_gameEmbedShape(_ msg: NetMessage) {
		let clientID  = Int(msg.readUInt32())
		let shape     = Piece.Shape(rawValue: Int(msg.readUInt32()))!
		let x         = Int(msg.readUInt32())
		let y         = Int(msg.readUInt32())
		let rotation  = Rotation(rawValue: Int(msg.readUInt32()))!
		
		let op = opponent(clientID: clientID)!
		let piece = Piece(shape: shape, position: Piece.Position(x, y), rotation: rotation)
		
		op.board.perform(action: BoardAction.placePiece(piece))
		
		// TODO: Either kill current shape (until we get a message for what it is)
		// or use the next piece in the normal initial position
		// op.currentPiece = op.nextPiece
	}



	fileprivate func handle_gameCompletedRows(_ msg: NetMessage) {
		var lines = IndexSet()
		let clientID = Int(msg.readUInt32())
		let numberOfRows = Int(msg.readUInt32())
		
		for _ in 0 ..< numberOfRows {
			lines.insert(Int(msg.readUInt32()))
		}
		
		let op = opponent(clientID: clientID)!
		op.board.perform(action: BoardAction.eraseLines(lines))
		
		// TODO play sound if numberOfRows == 4
	}



	fileprivate func handle_gamePlayerDied(_ msg: NetMessage) {
		let clientID = Int(msg.readUInt32())
		let op = opponent(clientID: clientID)!
		
		 op.isAlive = false
		// op.tower.fillSolid()
		// TODO play sound
	}


	fileprivate func handle_gameOver(_ msg: NetMessage) {
		let winnerClientID = Int(msg.readUInt32())
		if winnerClientID == state.localPlayer.clientID {
			wonGame()
		} else {
			lostGame()
		}
	}


	fileprivate func handle_returnToLobby(_ msg: NetMessage) {
		// TODO: pop scene
		
		//gameState.localPlayer.isReady = NO;
		//gameState.localPlayer.isAlive = NO;
	}

	
	
	
	
	
	
	private func toggleIsReady() {
		state.localPlayer.isReady = !state.localPlayer.isReady
		send(messageForLobbyReady())
	}
	
	
	func startGame() {
		
	}
	
	
	func wonGame() {
		
	}
	
	
	func lostGame() {
		
	}
}




// MARK: - 
struct GameState {
	
	// var levelNumber: Int
	// var gameRules: Rules -- until someone dies, or first to X lines complete, etc
	
	var localPlayer: Player = Player(name: "", clientID: 0)
	var players: [Player] = []
	
	var phase: Phase = .prepping
	var lastHorizontalMovementTime: TimeInterval = 0.0
	var lastVerticalMovementTime: TimeInterval = 0.0
	var lastRotationTime: TimeInterval = 0.0
	var lastFallingTime: TimeInterval = 0.0
	
	
	init() {
		
	}
	
	
	enum Phase: Int {
		case prepping, prepped, playing, watching, gameOver
	}
}





extension Piece {
	func proposed(by input: PlayerInput) -> Piece {
		var piece = self
		
		switch input {
		case .moveLeft:
			piece.position = Piece.Position(piece.position.x - 1, piece.position.y)
		
		case .moveRight:
			piece.position = Piece.Position(piece.position.x + 1, piece.position.y)
			
		case .moveDown:
			piece.position = Piece.Position(piece.position.x, piece.position.y - 1)
			
		case .rotateLeft:
			piece.rotation = piece.rotation.nextAnticlockwise()
			
		case .rotateRight:
			piece.rotation = piece.rotation.nextClockwise()
		
		default:
			preconditionFailure()
		}
		
		return piece
	}
}



extension PlayerInputMap {
	
	func rotatingAction() -> PlayerInput? {
		if self[.rotateLeft].active  { return .rotateLeft }
		if self[.rotateRight].active { return .rotateRight }
		if self[.rotateLeft].activated  { return .rotateLeft }
		if self[.rotateRight].activated { return .rotateRight }
		return nil
	}
	
	func horizontalMoveAction() -> PlayerInput? {
		if self[.moveLeft].active  { return .moveLeft }
		if self[.moveRight].active { return .moveRight }
		if self[.moveLeft].activated  { return .moveLeft }
		if self[.moveRight].activated { return .moveRight }
		return nil
	}
}




extension Prefs {
	static let playerName = Pref<String>("playerName")
	static let serverPort = Pref<Int>("serverPort")
	
	static var gameDefaults: [String: AnyObject] {
		return [
			playerName.key: "UnnamedPlayer" as AnyObject,
			serverPort.key: 2247 as AnyObject
		]
	}
}

