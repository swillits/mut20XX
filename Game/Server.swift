//
//  Server.swift
//  Project
//
//  Created by Seth Willits on 1/29/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation


/// Manages all clients, and the server's understanding of the game state
class ServerGame: NetConnectionDelegate {
	fileprivate var clients: [ServerClient] = []
	private var connectionToClientMap: [NetConnection: ServerClient] = [:]
	private var idForNextClient = 1
	private var serverConnection: NetConnection! = nil
	fileprivate var gameState = GameState()
	
	
	enum DropReason: Int {
		case serverIsFull = 1
		case serverShuttingDown = 2
		case gameInProgress = 3
		case clientLost = 4
		case playerNameNotUnique = 5
		case playerNameInvalid = 6
	}
	
	
	
	// MARK: - Listening, Client Connections 
	
	func start(port: Int) throws {
		precondition(serverConnection == nil)
		precondition(clients.isEmpty)
		precondition(connectionToClientMap.isEmpty)
		
		idForNextClient = 1
		gameState = GameState()
		
		serverConnection = NetConnection()
		serverConnection.delegate = self
		try serverConnection.accept(onPort: UInt16(port))
	}
	
	
	func stop() {
		for client in clients {
			dropClient(client, reason: .serverShuttingDown)
		}
		
		// Not sure this is needed since dropping should clear it. Be sure.
		assert(clients.isEmpty)
		assert(connectionToClientMap.isEmpty)
		//	clients = []
		//	connectionToClientMap = [:]
	}
	
	

	// MARK: - 
	
	private func addClient(for connection: NetConnection) {
		
		// Add client
		let client = ServerClient(connection: connection, clientID: idForNextClient)
		idForNextClient += 1
		
		client.connection.delegate = self
		clients.append(client)
		connectionToClientMap[connection] = client
		
		// Server full
		if clients.count >= Game.maxPlayers {
			dropClient(client, reason: .serverIsFull)
			return
		}
	}



	private func removeClient(for connection: NetConnection) {
		if let client = clientForConnection(connection: connection) {
			client.connection.delegate = nil
			
			let index = clients.index(of: client)!
			clients.remove(at: index)
			connectionToClientMap.removeValue(forKey: connection)
			
			//clientDidLeaveGame(client)
		}
	}



	private func clientForConnection(connection: NetConnection) -> ServerClient? {
		return connectionToClientMap[connection]
	}
	
	
	fileprivate func dropClient(_ client: ServerClient, reason: DropReason) {
		send(message: messageForDroppingConnection(reason: reason), to: client)
		client.connection.disconnectAfterWriting()
		removeClient(for: client.connection)
	}
	
	
	fileprivate func send(message: NetMessage, to client: ServerClient) {
		client.connection.write(NetPacket(number: 0, payload: message.data()))
	}
	
	
	
	
	// MARK: - 
	
	func connection(_ connection: NetConnection, didAcceptNewConnection newConnection: NetConnection) {
		if (connection == serverConnection) {
			addClient(for: newConnection)
			print("[Server] Accepted a new connection \(0)")
		}
	}
	
	
	func connectionDidDisconnect(_ connection: NetConnection, error: Error?) {
		print("[Server] Client disconnected.")
		removeClient(for: connection)
	}
	
	
	
	
	
	
	
	
	
	
	
	// MARK - Gameplay
	
	func update() {
		let now = NSDate.timeIntervalSinceReferenceDate
		
		
		// Check for messages from clients
		for client in clients {
			client.connection.queueRead()
			
			if client.connection.packetCount > 0 {
				let packets = client.connection.popPackets()
				client.lastPacketReceivedAtTime = now
				process(packets: packets, client: client)
			}
		}
		
		// Drop dead clients
		for client in clients {
			if now - client.lastPacketReceivedAtTime > 30.0 {
				dropClient(client, reason: .clientLost)
			}
		}
		
		
		
		// Update the game world
		// -- In a more typical game we would update the game
		// -- world state and then send state updates to each
		// -- of the clients, but in this game, we're doing it
		// -- differently.
		
		
		// Game Over
		// -----------------------------------------
//		if (mGamePhase == ServerGamePhaseGameOver) {
//			if (GBGetCurrentTime() - mStartOfGameOver > 5.0) {
//				
//				// Go back to the lobby
//				mGamePhase = ServerGamePhaseLobby;
//				
//				for (ServerClient * client in self.players) {
//					client.isReady = NO;
//					[self sendMessage:[self messageToReturnToLobby] toClient:client];
//				}
//				
//				GBNetMessage * msg = [self messageWithAllPlayersInfo];
//				for (ServerClient * client in self.players) {
//					[self sendMessage:msg toClient:client];
//				}
//			}
//		}
	}
	
}






// MARK: - Game State
extension ServerGame {
	
	fileprivate struct GameState {
		var phase: Phase = .lobby
		var startTimeOfGameOver: TimeInterval = 0.0
		
		var gameIsStarting = false
		var allPlayersPrepared = false
		var gameStarted = false
		
		enum Phase: Int {
			case lobby, prepping, playing, gameOver
		}
	}
	
	
	
	// MARK: - Handling Incoming Packets
	
	fileprivate func process(packets: [NetPacket], client: ServerClient) {		
		for packet in packets {
			let message = NetMessage(data: packet.payload)
			
			switch (message.type, message.subtype) {
			case (NetMessage.MsgType.playerConnection, NetMessage.PlayerConnectionSubtype.request):
				handle_playerConnectionRequest(client: client, message: message)
				
			case (NetMessage.MsgType.lobby, NetMessage.LobbySubtype.changedReady):
				handle_lobbyPlayerChangedReady(client: client, message: message)
				
			case (NetMessage.MsgType.game, _):
				switch message.subtype {
				case NetMessage.GameSubtype.isPrepared:
					handle_gameIsPrepared(client: client, message: message)
					
				case NetMessage.GameSubtype.shapes, NetMessage.GameSubtype.embedShape, NetMessage.GameSubtype.completedRows:
					handle_gameForwardClientMessage(fromClient: client, message: message)
					
				case NetMessage.GameSubtype.playerDied:
					handle_gamePlayerDied(client: client, message: message)
					
				default:
					break
				}
					
			default:
				break
			}
		}
	}
	
	
	
	private func handle_playerConnectionRequest(client: ServerClient, message: NetMessage) {
		
		// Is already playing, can't join
		if case .lobby = gameState.phase {
		} else {
			dropClient(client, reason: .gameInProgress)
			return
		}
		
		
		var rejectionReason: ServerGame.DropReason? = nil
		
		
		// -- Read Message --
		client.player.name = message.readString().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		
		
		// Validate the player (no duplicates or anything)
		if client.player.name.isEmpty {
			rejectionReason = .playerNameInvalid
		} else {
			for otherClient in clients {
				if client.clientID != otherClient.clientID {
					if client.player.name == otherClient.player.name {
						rejectionReason = .playerNameNotUnique
						break
					}
				}
			}
		}
		
		
		// Welcome! or GET OUT!
		if let rejectionReason = rejectionReason {
			dropClient(client, reason: rejectionReason)
		} else {
			clientDidJoinGame(client)
		}
	}
	
	
	
	private func handle_lobbyPlayerChangedReady(client: ServerClient, message: NetMessage) {
		// Take note
		client.player.isReady = message.readBool()
		
		// Notify everyone
		sendPlayersInfoToPlayers()
	}
	
	
	
	private func handle_gameIsPrepared(client: ServerClient, message: NetMessage) {
		client.player.gameIsPrepared = true
		
		// When everyone is, start the game
		if areAllPlayersPrepared() {
			isStartingGame()
		}
	}
	
	
	
	private func handle_gameForwardClientMessage(fromClient: ServerClient, message: NetMessage) {
		// Forward message from this client to all other clients
		// No need to change the message since it contains sender id
		
		for client in players() {
			if client.clientID != fromClient.clientID {
				send(message: message, to: client)
			}
		}
	}
	
	
	
	private func handle_gamePlayerDied(client: ServerClient, message: NetMessage) {
		// Let everyone know this player died
		client.player.isAlive = false
		handle_gameForwardClientMessage(fromClient: client, message: message)
		
		doGameOverIfNeeded()
	}
	
	
	
	private func clientDidJoinGame(_ client: ServerClient) {
		// Finalize the player
		// -----------------------------
		// <this game is simple>
		
		
		// Update the client
		// -----------------------------
		client.status = .joined
		
		
		// Add the player into the world
		// -----------------------
		// <using clients as official player list>
		
		
		// ------------------------
		// Tell the player they've been accepted
		send(message: messageForAcceptingConnection(client: client), to: client)
		
		// Send new list of players to everyone
		sendPlayersInfoToPlayers()
	}
	
	
	private func clientDidLeaveGame(_ client: ServerClient) {
		sendPlayersInfoToPlayers()
		doGameOverIfNeeded()
	}
	
	
	private func sendPlayersInfoToPlayers() {
		let msg = messageWithAllPlayersInfo()
		for client in players() {
			send(message: msg, to: client)
		}
	}
	
	
	
	private func players() -> [ServerClient] {
		var players: [ServerClient] = []
		
		for client in clients {
			switch client.status {
			case .disconnected, .zombie:
				break
			default:
				players.append(client)
			}
		}
		
		return players
	}



	private func areAllPlayersPrepared() -> Bool {
		var allPrepared = !players().isEmpty
		
		for client in players() {
			if !client.player.gameIsPrepared {
				allPrepared = false
				break
			}
		}
		
		return allPrepared
	}



	private func isStartingGame() {
		gameState.phase = .playing
		
		let msg = messageToStart()
		
		for client in players() {
			send(message: msg, to: client)
		}
	}
	
	
	
	private func doGameOverIfNeeded() {
		
		// Can only be game over if actually playing.
		// This method may be called when a client disconnects
		// (clientDidLeaveGame:) so we need to check the phase.
		if case .playing = gameState.phase {
			
			// Count how many players are alive
			var numPlayersAlive = 0
			var winnerClientID = 0
			for client in players() {
				if client.player.isAlive {
					winnerClientID = client.clientID
					numPlayersAlive += 1
				}
			}
			
			
			// If only 1, then notify that the game is over!
			if numPlayersAlive <= 1 {
				let msg = messageForGameOver(winnerClientID: winnerClientID)
				for client in players() {
					send(message: msg, to: client)
				}		
			}
			
			gameOver()
		}
	}


	private func gameOver() {
		// In 5 seconds, transition back to the lobby
		gameState.phase = .gameOver
		gameState.startTimeOfGameOver = NSDate.timeIntervalSinceReferenceDate
	}
	
	
	
	
	// MARK: - Outgoing
	
	fileprivate func messageForDroppingConnection(reason: ServerGame.DropReason) -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.playerConnection, subtype: NetMessage.PlayerConnectionSubtype.denied)
		msg.write(int8: Int8(reason.rawValue))
		return msg
	}
	
	
	private func messageForAcceptingConnection(client: ServerClient) -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.playerConnection, subtype: NetMessage.PlayerConnectionSubtype.granted)
		msg.write(uint32: UInt32(client.clientID))
		return msg
	}
	
	
	private func messageWithAllPlayersInfo() -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.general, subtype: NetMessage.GeneralSubtype.playersInfo)
		
		let players = self.players()
		msg.write(uint32: UInt32(players.count))
		
		for client in players {
			msg.write(uint32: UInt32(client.clientID))
			msg.write(string: client.player.name)
			msg.write(bool: client.player.isReady)
			msg.write(bool: client.player.isAlive)
		}
		
		return msg
	}
	
	
	private func messageToPrepare() -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.game, subtype: NetMessage.GameSubtype.prepare)
		return msg
	}
	
	
	private func messageToStart() -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.game, subtype: NetMessage.GameSubtype.start)
		return msg
	}
	
	
	private func messageForGameOver(winnerClientID: Int) -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.game, subtype: NetMessage.GameSubtype.gameOver)
		msg.write(uint32: UInt32(winnerClientID))
		return msg
	}


	private func messageToReturnToLobby() -> NetMessage {
		let msg = NetMessage(type: NetMessage.MsgType.game, subtype: NetMessage.GameSubtype.returnToLobby)
		return msg
	}
}














// MARK: - Server Client

typealias ClientID = Int

class ServerClient: Equatable {
	
	enum Status: Int, Equatable {
		case disconnected
		case zombie   // client will be disconnected and dropped soon
		case joined   // Has connected, but hasn't received a gamestate yet
		case primed   // gamestate has been sent, but client hasn't sent a usercmd
		case active   // client is fully in game and moving
	}
	
	
	// General Info
	// -----------------------
	private(set) var clientID: ClientID
	var status: Status
	private(set) var connection: NetConnection
	private(set) var connectedAtTime: TimeInterval
	var lastPacketReceivedAtTime: TimeInterval
	
	// In-Game Player Info
	// -----------------------
	var player: Player //! = nil
	
	
	init(connection: NetConnection, clientID: Int) {
		self.connection = connection
		self.clientID = clientID
		connectedAtTime = Date.timeIntervalSinceReferenceDate
		lastPacketReceivedAtTime = Date.timeIntervalSinceReferenceDate
		status = .disconnected
		
		player = Player(name: "<Unset>", clientID: clientID)
	}
	
	
	static func ==(lhs: ServerClient, rhs: ServerClient) -> Bool {
		return lhs === rhs
	}
}

