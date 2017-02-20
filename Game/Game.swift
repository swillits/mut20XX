//
//  Game.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation



/// Persistent object across games
class Game {
	private static let minimumTimeBetweenHorizontalMoves: TimeInterval = 0.1
	private static let minimumTimeBetweenVerticalMoves: TimeInterval = 0.1
	private static let normalTimeBetweenFalls: TimeInterval = 0.1
	private static let minimumTimeBetweenRotations: TimeInterval = 0.05
	static let minPiecePosition = Piece.Position(-4, -4)
	static let maxPiecePosition = Piece.Position(Board.width, Board.height)
	
	static let shared = Game()
	var state: GameState!
	
	let inputMap = PlayerInputMap()
	private var shapeGenerator = Piece.Shape.Generator()
	
	
	
	
	func newGame() {
		var localPlayer = Player(id: "local", name: "Local Player")
		localPlayer.state.score = 0
		localPlayer.state.isAlive = true
		localPlayer.state.ready = true
		localPlayer.state.gameLoaded = true
		
		let players = [localPlayer] // + [...]
		state = GameState(players: players, localPlayerID: localPlayer.id)
		inputMap.reset()
		advanceLocalPlayerPiece()
		advanceLocalPlayerPiece()
	}
	
	
	
	
	func start() {
		state.phase = .playing
	}
	
	
	
	func update(timing: UpdateTiming) {
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
		guard state.localPlayer.state.isAlive else {
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
		
		if inputMap[.drop].activated || inputMap[.drop].active {
			actOnFallingPiece(input: .drop, timing: timing)
		}
		
		updateFallingPiece(timing: timing)
		checkForCompletedLines()
	}
	
	
	
	private func updateFallingPiece(timing: UpdateTiming) {
		guard timing.now - state.lastFallingTime >= Game.normalTimeBetweenFalls else {
			return
		}
		
		let piece = state.localPlayer.state.currentPiece.proposed(by: .moveDown)
		if state.localPlayer.state.board.doesPositionCollide(piece: piece) {
			actOnFallingPiece(input: .drop, timing: timing)
		} else {
			state.localPlayer.state.currentPiece = piece
			state.lastFallingTime = timing.now
			// TODO: tell server
		}
	}
	
	
	
	private func checkForCompletedLines() {
		let linesRemoved = state.localPlayer.state.board.removeCompletedLines()
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
				let piece = state.localPlayer.state.currentPiece.proposed(by: input)
				if !state.localPlayer.state.board.doesPositionCollide(piece: piece) {
					playSound(for: input)
					state.localPlayer.state.currentPiece = piece
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
			var piece = state.localPlayer.state.currentPiece
			piece.position = state.localPlayer.state.board.finalPositionIfDropped(piece: state.localPlayer.state.currentPiece)
			advanceLocalPlayerPiece()
			state.lastFallingTime = timing.now
			// TODO: tell server
			
			
			if state.localPlayer.state.board.doesPieceSpillOverTop(piece: piece) {
				GameSound.collision.play()
				state.localPlayer.state.isAlive = false
			} else {
				GameSound.dropBlock.play()
			}
			
			state.localPlayer.state.board.perform(action: .placePiece(piece))
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
		state.localPlayer.state.currentPiece = state.localPlayer.state.nextPiece
		state.localPlayer.state.nextPiece = Piece(shape: shapeGenerator.nextShape(), position: Board.initialPiecePosition, rotation: .north)
	}
	
	
	
	struct UpdateTiming {
		
		/// Absolute time of the frame
		let now: TimeInterval
		
		/// Delta since previous update
		let delta: TimeInterval
	}
}




/// The state of the current game.
struct GameState {
	
	// Shared values for all clients
	// ---------------------------------------------------
	// var levelNumber: Int
	// var gameRules: Rules -- until someone dies, or first to X lines complete, etc
	var players: [PlayerID: Player]
	
	// --------- Local-client-only state ------------------
	// When server/client split happens, this'll go somewhere better
	let localPlayerID: String
	var phase: Phase = .prepping
	var lastHorizontalMovementTime: TimeInterval = 0.0
	var lastVerticalMovementTime: TimeInterval = 0.0
	var lastRotationTime: TimeInterval = 0.0
	var lastFallingTime: TimeInterval = 0.0
	// -----------------------------------------------------
	
	
	init(players: [Player], localPlayerID: PlayerID) {
		self.localPlayerID = localPlayerID
		self.players = {
			var dict: [PlayerID: Player] = [:]
			for player in players {
				dict[player.id] = player
			}
			return dict
		}()
	}
	
	
	// Sure seems like this may be quite inefficient, where updating any state in the local player has to go through this hashing, but the syntax is convenient. It could be stored outside of `players` too, but perhaps that'll make looping annoying. Heading down this route for now.
	var localPlayer: Player {
		get {
			return players[localPlayerID]!
		}
		set {
			players[localPlayerID] = newValue
		}
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
