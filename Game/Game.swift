//
//  Game.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation


struct Game {
	static let minimumTimeBetweenHorizontalMoves: TimeInterval = 0.1
	static let minimumTimeBetweenVerticalMoves: TimeInterval = 0.1
	static let normalTimeBetweenFalls: TimeInterval = 1.0
	static let minimumTimeBetweenRotations: TimeInterval = 0.15
	
	static let maxPlayers = 5
	static let minPiecePosition = Piece.Position(-4, -4)
	static let maxPiecePosition = Piece.Position(Board.width, Board.height)
}


/// Persistent object across games, on the client
class ClientGame: NetConnectionDelegate {
	
	var state: GameState!
	
	let inputMap = PlayerInputMap()
	private var shapeGenerator = Piece.Shape.Generator()
	
	
	
	init() {
		// TODO: Connect to prefs and UI
		inputMap.setTriggers([.keycode(Keycode.space)],      for: .drop)
		inputMap.setTriggers([.keycode(Keycode.downArrow)],  for: .moveDown)
		inputMap.setTriggers([.keycode(Keycode.leftArrow)],  for: .moveLeft)
		inputMap.setTriggers([.keycode(Keycode.rightArrow)], for: .moveRight)
		inputMap.setTriggers([.keycode(Keycode.a)],          for: .rotateLeft)
		inputMap.setTriggers([.keycode(Keycode.d)],          for: .rotateRight)
	}
	
	
	
	
	func newGame() {
		
		state = GameState()
		
		state.localPlayer.clientID = 0
		state.localPlayer.name = "Local Player"
		
		state.localPlayer.score = 0
		state.localPlayer.isAlive = true
		state.localPlayer.isReady = true
		state.localPlayer.gameIsPrepared = true
		
		
		inputMap.reset()
		advanceLocalPlayerPiece()
		advanceLocalPlayerPiece()
	}
	
	
	
	
	// MARK: - Connection to Server
	
	private var connection: NetConnection? = nil
	private var clientStatus: ClientStatus = .uninitialized
	private var connectedAtTime: TimeInterval = 0.0
	private var lastPacketAtTime: TimeInterval = 0.0
	private var connectHandler: ((Error?) -> ())? = nil
	
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
		connection = NetConnection()
		connection?.delegate = self
		try! connection?.connect(host: serverAddress, port: port, timeout: 10.0)
	}
	
	
	func disconnect() {
		clientStatus = .disconnected
		
		connection?.disconnectAfterWriting()
		connection?.delegate = nil
		connection = nil
		
		// TODO ... go back to previous scene
		// display reasonToDisplay
		// [[GBSceneManager sharedManager] popScene]; // ??
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
		
		// Send Player info
		//sendMessage(messageAfterConnecting())
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
//		[mConnectionToServer queueRead];
//		if ([mConnectionToServer packetCount]) {
//			mTimeOfLastPacket = GBGetCurrentTime();
//			[self processPackets:[mConnectionToServer popPackets]];
//		}
		
		// Drop the connection if we haven't received an update in a long time... (only needed if using UDP)
//		if ((GBGetCurrentTime() - mConnectedAtTime > 60.0) || (GBGetCurrentTime() - mTimeOfLastPacket > 30.0)) {
//			//[self dropClient:client reason:@"Haven't heard from you in 30 seconds."];
//		}
		
		
		
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
	
	
	
	struct UpdateTiming {
		
		/// Absolute time of the frame
		let now: TimeInterval
		
		/// Delta since previous update
		let delta: TimeInterval
	}
}




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

