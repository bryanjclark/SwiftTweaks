//
//  TweakButton.swift
//  SwiftTweaks
//
//  Created by Jarosław Pendowski on 28/04/2017.
//  Copyright © 2017 Khan Academy. All rights reserved.
//

import UIKit

final class TweakButton: UIButton {
	
	typealias ControlState = UInt
	
	@objc private var borderColors: [ControlState: UIColor] = [:]
	
	override var isHighlighted: Bool {
		didSet { updateState() }
	}
	
	override var isEnabled: Bool {
		didSet { updateState() }
	}
	
	@objc var borderWidth: CGFloat = 2 {
		didSet { updateState() }
	}
	
	@objc var cornerRadius: CGFloat = 4 {
		didSet { updateState() }
	}
	
	func setBorderColor(_ color: UIColor, for state: UIControlState = .normal) {
		borderColors[state.rawValue] = color
		updateState()
	}
	
	func borderColor(for state: UIControlState) -> UIColor? {
		return borderColors[state.rawValue]
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		updateState()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		// NSCoder doesn't get CGFloats, and although is a Double _right now_, we could use a little trick to avoid casing
		borderWidth = aDecoder.decodeCGVector(forKey: #keyPath(borderWidth)).dx
		cornerRadius = aDecoder.decodeCGVector(forKey: #keyPath(cornerRadius)).dx
		
		if let colorsString = aDecoder.decodeObject(forKey: #keyPath(borderColors)) as? String {
			borderColors = type(of: self).decodeBorderColors(from: colorsString)
		}
		
		updateState()
	}
	
	override func encode(with aCoder: NSCoder) {
		super.encode(with: aCoder)
		
		aCoder.encode(CGVector(dx: borderWidth, dy: 0), forKey: #keyPath(borderWidth))
		aCoder.encode(CGVector(dx: cornerRadius, dy: 0), forKey: #keyPath(cornerRadius))
		aCoder.encode(type(of: self).encodeBorderColors(from: borderColors), forKey: #keyPath(borderColors))
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
	
	private static func encodeBorderColors(from colors: [ControlState: UIColor]) -> String {
		var encodedString = ""
		for (state, color) in colors {
			encodedString += "\(state):\(color.hexString)|"
		}
		return encodedString
	}
	
	private static func decodeBorderColors(from string: String) -> [ControlState: UIColor] {
		var colors: [ControlState: UIColor] = [:]
		let pairs = string.components(separatedBy: "|")
		pairs.forEach {
			let pair = $0.components(separatedBy: ":")
			guard pair.count == 2,
				let state = ControlState(pair[0]),
				let color = UIColor.colorWithHexString(pair[1]) else{
				return
			}
			colors[state] = color
		}
		return colors
	}
}
