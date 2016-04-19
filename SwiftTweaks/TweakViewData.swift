//
//  TweakViewData.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/19/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

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
		case let .Integer(value: intValue, _, _, _, _):
			return intValue
		case let .Float(value: floatValue, _, _, _, _):
			return floatValue
		case let .DoubleTweak(value: doubleValue, _, _, _, _):
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
		case let .Integer(value: value, defaultValue: defaultValue, _, _, _):
			string = "Int(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .Float(value: value, defaultValue: defaultValue, _, _, _):
			string = "Float(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .DoubleTweak(value: value, defaultValue: defaultValue, _, _, _):
			string = "Double(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .Color(value: value, defaultValue: defaultValue):
			string = "Color(\(value.hexString), alpha: \(value.alphaValue))"
			differsFromDefault = (value != defaultValue)
		}
		return (string, differsFromDefault)
	}

	private var isSignedNumberType: Bool {
		switch self {
		case .Integer, .Float, .DoubleTweak:
			return true
		case .Boolean, .Color:
			return false
		}
	}

	// These are the defaults that UIKit has for the UIStepper min and max
	internal static let stepperDefaultMinimum: Double = 0
	internal static let stepperDefaultMaximum: Double = 100

	/// Used when no max is given and the default is > stepperDefaultMaximum
	internal static let stepperBoundsMultiplier: Double = 2

	/// UISteppers *require* a maximum value (ugh) and they default to 100 (ughhhh)
	/// ...so let's set something sensible.
	var stepperLimits: (stepperMin: Double, stepperMax: Double)? {
		precondition(self.isSignedNumberType)

		let currentValue: Double
		let defaultValue: Double
		let minimum: Double?
		let maximum: Double?

		switch self {
		case .Boolean, .Color:
			return nil

		case let .Integer(intValue, intDefaultValue, intMin, intMax, _):
			currentValue = Double(intValue)
			defaultValue = Double(intDefaultValue)
			minimum = intMin.map(Double.init)
			maximum = intMax.map(Double.init)

		case let .Float(floatValue, floatDefaultValue, floatMin, floatMax, _):
			currentValue = Double(floatValue)
			defaultValue = Double(floatDefaultValue)
			minimum = floatMin.map(Double.init)
			maximum = floatMax.map(Double.init)

		case let .DoubleTweak(doubleValue, doubleDefaultValue, doubleMin, doubleMax, _):
			currentValue = doubleValue
			defaultValue = doubleDefaultValue
			minimum = doubleMin
			maximum = doubleMax

		}

		// UIStepper defaults to 0 and 100, so we'll use those as a fallback.
		var resultMin: Double = TweakViewData.stepperDefaultMinimum
		var resultMax: Double = TweakViewData.stepperDefaultMaximum

		// If we have a currentValue or defaultValue that's outside the bounds, we'll want to give some space to 'em.
		if (defaultValue < resultMin) || (currentValue < resultMin) {
			let lowerValue = min(currentValue, defaultValue)
			resultMin = (lowerValue < 0) ?
				lowerValue * TweakViewData.stepperBoundsMultiplier :
				lowerValue / TweakViewData.stepperBoundsMultiplier
		}

		if (defaultValue > resultMax) || (currentValue > resultMax) {
			let upperValue = max(currentValue, defaultValue)
			resultMax = (upperValue < 0) ?
				upperValue / TweakViewData.stepperBoundsMultiplier :
				upperValue * TweakViewData.stepperBoundsMultiplier
		}

		// Lastly, to override any above work: if an explicit minimum or maximum were given,
		// we'd want to use that instead.
		resultMin = minimum ?? resultMin
		resultMax = maximum ?? resultMax

		return (resultMin, resultMax)
	}

}