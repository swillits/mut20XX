//
//  ShapeNode.swift
//  Project
//
//  Created by Seth Willits on 2/18/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation
import SpriteKit


class ShapeNode: SKNode {
	
	static let xOffset = (CGFloat(Piece.Shape.width)  * BlockNode.size.width) / 2.0
	static let yOffset = (CGFloat(Piece.Shape.height) * BlockNode.size.height) / 2.0
	
	init(shape: Piece.Shape) {
		self.shape = shape
		
		super.init()
		
		for x in 0 ..< shape.occupancyMap.width {
			for y in 0 ..< shape.occupancyMap.height {
				if case let .filled(variety) = shape.occupancyMap[x, y] {
					let pbn = BlockNode(variety: variety)
					pbn.position = CGPoint(x: -ShapeNode.xOffset + CGFloat(x) * BlockNode.size.width, y: -ShapeNode.yOffset + CGFloat(y) * BlockNode.size.height)
					addChild(pbn)
				}
			}
		}
	}
	
	
	let shape: Piece.Shape
	
	
	var rotation: Rotation = .north {
		didSet {
			switch rotation {
			case .north:
				zRotation = 0
			case .east:
				zRotation = 3 * CGFloat.pi / 2
			case .south:
				zRotation = CGFloat.pi
			case .west:
				zRotation = CGFloat.pi / 2
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

