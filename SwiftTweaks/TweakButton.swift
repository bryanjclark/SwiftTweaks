//
//  TweakButton.swift
//  SwiftTweaks
//
//  Created by Jarosław Pendowski on 28/04/2017.
//  Copyright © 2017 Khan Academy. All rights reserved.
//

import UIKit

class TweakButton: UIButton {
	
	typealias ControlState = UInt
	
	private var borderColors: [ControlState: UIColor] = [:]
	override var isHighlighted: Bool {
		didSet { updateState() }
	}
	
	override var isEnabled: Bool {
		didSet { updateState() }
	}
	
	var borderWidth: CGFloat = 2 {
		didSet { updateState() }
	}
	
	var cornerRadius: CGFloat = 4 {
		didSet { updateState() }
	}
	
	func setBorderColor(color: UIColor, for state: UIControlState = .normal) {
		borderColors[state.rawValue] = color
	}
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		
		updateState()
	}
	
	// MARK: - Private
	
	private func updateState() {
		let color = borderColors[state.rawValue]
		layer.borderColor = color?.cgColor
		layer.borderWidth = borderWidth
		layer.cornerRadius = cornerRadius
	}
	
	override func sizeThatFits(_ size: CGSize) -> CGSize {
		var size = super.sizeThatFits(size)
		
		size.width += borderWidth * 2
		size.height += borderWidth * 2
		
		return size
	}
}
