//
//  Communication.swift
//  Project
//
//  Created by Seth Willits on 1/29/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation


enum NetworkMessages {
	
	// Server to Clients
	// =========================================
	
	// Lobby
	// -------------------------
	
	
	
	
	// Gameplay
	// -------------------------
	
	case addLinesToBottom // to specific client with line count
	case gameOver // with winner
	
	// replication of client gameplay messages
	// ...
	
	
	
	// Clients to Server
	// =========================================
	
	// Lobby
	// -------------------------
	case setPlayerReady
	
	
	
	// Gameplay
	// -------------------------
	case setPlayerGamePrepared
	case setNextPiece
	case setCurrentPiece
	case setPieceLocation
	case completedLines
	case lost
	
	 
	
	
}
