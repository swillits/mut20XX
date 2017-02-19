//
//  PieceNode.swift
//  Project
//
//  Created by Seth Willits on 2/18/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation
import SpriteKit


class PieceNode: SKNode {
	
	// Has a 4x4 grid of pieceblock nodes, simply updates the PieceBlockNodes whenever the piece changes
	
	
	var piece: Piece = Piece.placeholder {
		didSet {
			
		}
	}
	
	
}

