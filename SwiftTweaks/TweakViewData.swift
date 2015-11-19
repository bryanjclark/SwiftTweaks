//
//  TweakViewData.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/19/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

/// View data used to populate our table cells
internal enum TweakViewData {
	case Boolean(value: Bool, defaultValue: Bool)
	case Integer(value: Int, defaultValue: Int, min: Int?, max: Int?, stepSize: Int?)
	case Float(value: CGFloat, defaultValue: CGFloat, min: CGFloat?, max: CGFloat?, stepSize: CGFloat?)
	case DoubleTweak(value: Double, defaultValue: Double, min: Double?, max: Double?, stepSize: Double?)
	case Color(value: UIColor, defaultValue: UIColor)

	init<T: TweakableType>(type: TweakViewDataType, value: T, defaultValue: T, minimum: T?, maximum: T?, stepSize: T?) {
		switch type {
		case .Boolean:
			self = .Boolean(value: value as! Bool, defaultValue: defaultValue as! Bool)
		case .UIColor:
			self = .Color(value: value as! UIColor, defaultValue: defaultValue as! UIColor)
		case .Integer:
			let clippedValue = clip(value as! Int, minimum as? Int, maximum as? Int)
			self = .Integer(value: clippedValue, defaultValue: defaultValue as! Int, min: minimum as? Int, max: maximum as? Int, stepSize: stepSize as? Int)
		case .CGFloat:
			let clippedValue = clip(value as! CGFloat, minimum as? CGFloat, maximum as? CGFloat)
			self = .Float(value: clippedValue, defaultValue: defaultValue as! CGFloat, min: minimum as? CGFloat, max: maximum as? CGFloat, stepSize: stepSize as? CGFloat)
		case .Double:
			let clippedValue = clip(value as! Double, minimum as? Double, maximum as? Double)
			self = .DoubleTweak(value: clippedValue, defaultValue: defaultValue as! Double, min: minimum as? Double, max: maximum as? Double, stepSize: stepSize as? Double)
		}
	}

	var value: TweakableType {
		switch self {
		case let .Boolean(value: boolValue, defaultValue: _):
			return boolValue
		case let .Integer(value: intValue, defaultValue: _, min: _, max: _, stepSize: _):
			return intValue
		case let .Float(value: floatValue, defaultValue: _, min: _, max: _, stepSize: _):
			return floatValue
		case let .DoubleTweak(value: doubleValue, defaultValue: _, min: _, max: _, stepSize: _):
			return doubleValue
		case let .Color(value: colorValue, defaultValue: _):
			return colorValue
		}
	}

	var stringRepresentation: (String, Bool) {
		let string: String
		let differsFromDefault: Bool
		switch self {
		case let .Boolean(value: value, defaultValue: defaultValue):
			string = value ? "Bool(true)" : "Bool(false)"
			differsFromDefault = (value != defaultValue)
		case let .Integer(value: value, defaultValue: defaultValue, min: _, max: _, stepSize: _):
			string = "Int(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .Float(value: value, defaultValue: defaultValue, min: _, max: _, stepSize: _):
			string = "Float(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .DoubleTweak(value: value, defaultValue: defaultValue, min: _, max: _, stepSize: _):
			string = "Double(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .Color(value: value, defaultValue: defaultValue):
			string = "Color(\(value.hexString), alpha: \(value.alphaValue))"
			differsFromDefault = (value != defaultValue)
		}
		return (string, differsFromDefault)
	}
}
