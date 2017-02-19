//
//  PieceBlockNode.swift
//  Project
//
//  Created by Seth Willits on 2/18/17.
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Foundation
import SpriteKit


class PieceBlockNode: SKSpriteNode {
	
	static let size: CGSize = CGSize(width: 24, height: 24)
	
	init(variety: BlockVariety? = nil) {
		super.init(texture: nil, color: NSColor.clear, size: PieceBlockNode.size)
		self.variety = variety
		updateAppearanceFromVariety()
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		preconditionFailure()
	}
	
	
	var variety: BlockVariety? = nil {
		didSet {
			updateAppearanceFromVariety()
		}
	}
	
	private func updateAppearanceFromVariety() {
		if let v = variety {
			switch v {
			case .a: color = NSColor.blue
			case .b: color = NSColor.yellow
			case .c: color = NSColor.cyan
			case .d: color = NSColor.purple
			case .e: color = NSColor.orange
			case .f: color = NSColor.green
			case .g: color = NSColor.red
			case .wall: color = NSColor.darkGray
			}
		} else {
			color = NSColor.clear
		}
	}
	
}

