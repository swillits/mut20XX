//
//  BoardNode.swift
//  Project
//
//  Created by Seth Willits on 2/18/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation
import SpriteKit


class BoardNode: SKNode {
	
	
	// has a 12 x 21 grid of piece nodes, and a Board property,
	// each time Board changes, just change the BlockNodes to reflect
	
	override init() {
		super.init()
		setupBoard()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupBoard()
	}
	
	
	
	var board: Board = Board() {
		didSet {
			for x in 0 ..< Board.width {
				for y in 0 ..< Board.height {
					switch board.map[x, y] {
					case .vacant:
						self[x, y].variety = nil
					case let .filled(variety):
						self[x, y].variety = variety
					}
				}
			}
			
			
			
//			self[0, 15].variety = .a
//			self[1, 15].variety = .b
//			self[2, 15].variety = .c
//			self[3, 15].variety = .d
//			self[4, 15].variety = .e
//			self[5, 15].variety = .f
//			self[6, 15].variety = .g
//			self[7, 15].variety = .c
//			self[8, 15].variety = .b
//			self[9, 15].variety = .a
		}
	}
	
	
	var fallingPiece: Piece? = nil {
		didSet {
			if let piece = fallingPiece {
				if fallingShapeNode == nil || piece.shape != fallingShapeNode!.shape {
					fallingShapeNode?.removeFromParent()
					fallingShapeNode = ShapeNode(shape: piece.shape)
					addChild(fallingShapeNode!)
				}
				
				fallingShapeNode!.position = shapeNodePoint(for: piece.position)
				fallingShapeNode!.rotation = piece.rotation
			} else {
				fallingShapeNode?.removeFromParent()
				fallingShapeNode = nil
			}
		}
	}
	
	
	
	private var grid: [BlockNode] = []
	private var fallingShapeNode: ShapeNode? = nil
	
	private func setupBoard() {
		let count = (Board.width + 2) * (Board.height + 1)
		
		for _ in 0 ..< count {
			let node = BlockNode(variety: nil)
			grid.append(node)
			addChild(node)
		}
		
		for x in -1 ... Board.width {
			for y in -1 ..< Board.height {
				self[x, y].position = blockNodePoint(for: Piece.Position(x, y))
			}
		}
		
		for x in -1 ... Board.width {
			self[x, -1].variety = .wall
		}
		
		for y in 0 ..< Board.height {
			self[-1, y].variety = .wall
			self[Board.width, y].variety = .wall
		}
	}
	
	
	
	private subscript(x: Int, y: Int) -> BlockNode {
		get {
			precondition(x >= -1)
			precondition(x <= Board.width + 1)
			precondition(y >= -1)
			precondition(y <= Board.height)
			return grid[(y + 1) * (Board.width + 2) + (x + 1)]
		}
	}
	
	
	private func blockNodePoint(for p: Piece.Position) -> CGPoint {
		return CGPoint(x: CGFloat(p.x + 1) * BlockNode.size.width, y: CGFloat(p.y + 1) * BlockNode.size.height)
	}
	
	
	func shapeNodePoint(for p: Piece.Position) -> CGPoint {
		// Like blockNodePoint(for:), except the origin of a shape is its center, not bottom left, So to align the bottom left block of the shape with blockNodePoint(for: p) we have to offset by shape's radius
		var point = blockNodePoint(for: p)
		point.x += ShapeNode.xOffset
		point.y += ShapeNode.yOffset
		return point
	}
}

