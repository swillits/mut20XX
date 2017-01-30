//
//  Game.swift
//  MUT20XX
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation



// Persistent object across games
class Game {
	private static let minimumTimeBetweenHorizontalMoves: TimeInterval = 0.1
	private static let normalTimeBetweenVerticalMoves: TimeInterval = 1.0
	
	
	static let shared = Game()
	var state: GameState!
	
	
	
	
	func newGame() {
		let localPlayer = Player(id: "local", name: "Local Player")
		let players = [localPlayer] // + [...]
		state = GameState(players: players, localPlayerID: localPlayer.id)
	}
	
	
	
	
	func start() {
		state.playing = true
	}
	
	
	
	
	func update() {
		let now = NSDate.timeIntervalSinceReferenceDate
		
		if state.playing {
			if state.localPlayer.state.isAlive {
				if now - state.localPlayerState.lastHorizontalMovementTime > Game.minimumTimeBetweenHorizontalMoves {
					
					// TODO: If move left held down, then do left, else if right then move right etc...
					if true {
						state.localPlayerState.lastHorizontalMovementTime = now
						moveLeft()
					}
				}
				
				
				if now - state.lastVerticalMovementTime >= Game.normalTimeBetweenVerticalMoves {
					updateFallingPiece()
					state.lastVerticalMovementTime = now
				}
			}
		}
	}
	
	
	
	
	
	private func moveLeft() {
		//	- valid move?
		//		- play sound
		//		- update local piece position
		//		- tell server
		
		
	}
	
	
	
	private func updateFallingPiece() {
		// if one spot down is invalid, then place the piece where it is, otherwise move it down
	} 
}




// The state of the current game.
// Not liking the funkiness of separate player state and local state. Using 'class' vs struct for Player and LocalPlayer makes it a bit more referrentially pleasing and efficient to update, but I thought having the goal of GameState be One Massive Struct could be useful at some point in the future, particularly for replays etc. So, because of that, we're suffering the wonkiness for now until a better thought comes along.  
struct GameState {
	
	var players: [PlayerID: Player]
	var localPlayerState = LocalPlayerState()
	let localPlayerID: String
	
	var playing: Bool = false
	// var levelNumber: Int
	// var gameRules: Rules -- until someone dies, or first to X lines complete, etc
	
	var lastVerticalMovementTime: TimeInterval = 0.0
	
	
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
