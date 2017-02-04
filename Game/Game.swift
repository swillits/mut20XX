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
	private static let normalTimeBetweenFalls: TimeInterval = 1.0
	private static let minimumTimeBetweenRotations: TimeInterval = 0.05
	static let minPiecePosition = Piece.Position(x: -4, y: -4)
	static let maxPiecePosition = Piece.Position(x: Board.width, y: Board.height)
	
	static let shared = Game()
	var state: GameState!
	
	let inputMap = PlayerInputMap()
	
	
	
	
	func newGame() {
		let localPlayer = Player(id: "local", name: "Local Player")
		let players = [localPlayer] // + [...]
		state = GameState(players: players, localPlayerID: localPlayer.id)
	}
	
	
	
	
	func start() {
		state.phase = .playing
	}
	
	
	
	func update(timing: UpdateTiming) {
		switch state.phase {
		case .prepped:
			return
			
		case .gameOver:
			return
			
		case .watching:
			return
			
		case .playing:
			updateLocalPlayer(timing: timing)
		}
		
		inputMap.clearActivated()
	}
	
	
	
	private func updateLocalPlayer(timing: UpdateTiming) {
		func rotatingAction() -> PlayerInput? {
			if inputMap[.rotateLeft].active  { return .rotateLeft }
			if inputMap[.rotateRight].active { return .rotateRight }
			if inputMap[.rotateLeft].activated  { return .rotateLeft }
			if inputMap[.rotateRight].activated { return .rotateRight }
			return nil
		}
		
		func horizontalAction() -> PlayerInput? {
			if inputMap[.moveLeft].active  { return .moveLeft }
			if inputMap[.moveRight].active { return .moveRight }
			if inputMap[.moveLeft].activated  { return .moveLeft }
			if inputMap[.moveRight].activated { return .moveRight }
			return nil
		}
		
		
		
		guard state.localPlayer.state.isAlive else {
			return
		}
		
		if let action = rotatingAction() {
			rotateFallingPiece(input: action, timing: timing)
		}
		
		if let action = horizontalAction() {
			moveFallingPiece(input: action, timing: timing)
		}
		
		if inputMap[.moveDown].activated {
			moveFallingPieceDown(timing: timing)
		}
		
		if inputMap[.drop].activated {
			dropFallingPiece(timing: timing)
		}
		
		
		updateFallingPiece(timing: timing)
		
		
		// TODO: Check for completed lines
	}
	
	
	
	private func rotateFallingPiece(input: PlayerInput, timing: UpdateTiming) {
		precondition(input == .rotateLeft || input == .rotateRight)
		guard timing.now - state.lastRotationTime > Game.minimumTimeBetweenRotations else {
			return
		}
		
		let piece = state.localPlayer.state.currentPiece.proposed(by: input)
		if state.localPlayer.state.board.doesPositionCollide(piece: piece) {
			GameSound.rotateBlock.play()
			state.localPlayer.state.currentPiece = piece
			state.lastRotationTime = timing.now
			
			// TODO: tell server
		}
	}
	
	
	
	private func moveFallingPiece(input: PlayerInput, timing: UpdateTiming) {
		precondition(input == .moveLeft || input == .moveRight)
		guard timing.now - state.lastHorizontalMovementTime > Game.minimumTimeBetweenHorizontalMoves else {
			return
		}
		
		let piece = state.localPlayer.state.currentPiece.proposed(by: input)
		if state.localPlayer.state.board.doesPositionCollide(piece: piece) {
			GameSound.moveBlock.play()
			state.localPlayer.state.currentPiece = piece
			state.lastHorizontalMovementTime = timing.now
			
			// TODO: tell server
		}
	}
	
	
	
	private func moveFallingPieceDown(timing: UpdateTiming) {
		guard timing.now - state.lastVerticalMovementTime > Game.minimumTimeBetweenVerticalMoves else {
			return
		}
		
		let piece = state.localPlayer.state.currentPiece.proposed(by: .moveDown)
		if state.localPlayer.state.board.doesPositionCollide(piece: piece) {
			GameSound.moveBlock.play()
			state.localPlayer.state.currentPiece = piece
			state.lastVerticalMovementTime = timing.now
			
			// TODO: tell server
		}
	}
	
	
	
	private func updateFallingPiece(timing: UpdateTiming) {
		guard timing.now - state.lastFallingTime >= Game.normalTimeBetweenFalls else {
			return
		}
		
		let piece = state.localPlayer.state.currentPiece.proposed(by: .moveDown)
		if state.localPlayer.state.board.doesPositionCollide(piece: piece) {
			dropFallingPiece(timing: timing)
		} else {
			state.localPlayer.state.currentPiece = piece
			state.lastFallingTime = timing.now
			
			// TODO: tell server
		}
	}
	
	
	
	private func dropFallingPiece(timing: UpdateTiming) {
		var piece = state.localPlayer.state.currentPiece
		piece.position = state.localPlayer.state.board.finalPositionIfDropped(piece: state.localPlayer.state.currentPiece)
		state.localPlayer.state.currentPiece = piece
		state.lastFallingTime = timing.now
		GameSound.dropBlock.play()
		
		// TODO: tell server
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
	var phase: Phase = .prepped
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
	
	
	
	// Mmmm… perhaps all of those actions/methods which manipulate the GameState which are in Game above should be mutating methods in GameState itself.
	
	
	
	enum Phase: Int {
		case prepped, playing, watching, gameOver
	}
}





/*

-----------------------
Player Input
-----------------------

Movement:
	key down sets flag, resets time of last press
	key up clears flag



Move Left/Right/Down
	- valid move?
		- play sound
		- update local piece position
		- tell server

Rotate
	- Create a temporary piece with new rotation
	- Is it not a valid move?
		- Try moving one once to the right. If valid, move temp piece location.
		- Otherwise, try left one.
		- Next try two right, then two left.
	- Finally, if it is a valid location
		- play sound
		- update local piece
		- tell server

Drop
	- Get final location
	- Place it (see placement below)


Placement
	- If spilling over the top
		LostGame
	- else
		- Play sound
		- Tell server
		- Check for complete lines
		- Change to next shape
		

Checking complete lines
	- get them, erase lines
	- if == 4 shake camera
		play four sound
	- else
		play normal sound
	- score update
	- tell server


Add lines to bottom
	- play suck sound
	- if lines == 4 then shake camera
	





-----------------------
Game Prep on Client
-----------------------

- Load the correct scene for the given number of players
- Setup scene with the players
- Pick current and next shapes
- Tell the server that the client is prepped




-----------------------
Client - Game Start
-----------------------

- Allow movement
- Start the game loop



-----------------------
Client - Game over
-----------------------

- Disallow movement
- Stop music
- Move to 



*/









extension Piece {
	
	func proposed(by input: PlayerInput) -> Piece {
		var piece = self
		
		switch input {
		case .moveLeft:
			piece.position = Piece.Position(x: piece.position.x - 1, y: piece.position.y)
		
		case .moveRight:
			piece.position = Piece.Position(x: piece.position.x + 1, y: piece.position.y)
			
		case .moveDown:
			piece.position = Piece.Position(x: piece.position.x, y: piece.position.y - 1)
			
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

