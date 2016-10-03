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
	case boolean(value: Bool, defaultValue: Bool)
	case integer(value: Int, defaultValue: Int, min: Int?, max: Int?, stepSize: Int?)
	case float(value: CGFloat, defaultValue: CGFloat, min: CGFloat?, max: CGFloat?, stepSize: CGFloat?)
	case doubleTweak(value: Double, defaultValue: Double, min: Double?, max: Double?, stepSize: Double?)
	case color(value: UIColor, defaultValue: UIColor)

	init<T: TweakableType>(type: TweakViewDataType, value: T, defaultValue: T, minimum: T?, maximum: T?, stepSize: T?) {
		switch type {
		case .boolean:
			self = .boolean(value: value as! Bool, defaultValue: defaultValue as! Bool)
		case .uiColor:
			self = .color(value: value as! UIColor, defaultValue: defaultValue as! UIColor)
		case .integer:
			let clippedValue = clip(value as! Int, minimum as? Int, maximum as? Int)
			self = .integer(value: clippedValue, defaultValue: defaultValue as! Int, min: minimum as? Int, max: maximum as? Int, stepSize: stepSize as? Int)
		case .cgFloat:
			let clippedValue = clip(value as! CGFloat, minimum as? CGFloat, maximum as? CGFloat)
			self = .float(value: clippedValue, defaultValue: defaultValue as! CGFloat, min: minimum as? CGFloat, max: maximum as? CGFloat, stepSize: stepSize as? CGFloat)
		case .double:
			let clippedValue = clip(value as! Double, minimum as? Double, maximum as? Double)
			self = .doubleTweak(value: clippedValue, defaultValue: defaultValue as! Double, min: minimum as? Double, max: maximum as? Double, stepSize: stepSize as? Double)
		}
	}

	var value: TweakableType {
		switch self {
		case let .boolean(value: boolValue, defaultValue: _):
			return boolValue
		case let .integer(value: intValue, _, _, _, _):
			return intValue
		case let .float(value: floatValue, _, _, _, _):
			return floatValue
		case let .doubleTweak(value: doubleValue, _, _, _, _):
			return doubleValue
		case let .color(value: colorValue, defaultValue: _):
			return colorValue
		}
	}

	var stringRepresentation: (String, Bool) {
		let string: String
		let differsFromDefault: Bool
		switch self {
		case let .boolean(value: value, defaultValue: defaultValue):
			string = value ? "Bool(true)" : "Bool(false)"
			differsFromDefault = (value != defaultValue)
		case let .integer(value: value, defaultValue: defaultValue, _, _, _):
			string = "Int(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .float(value: value, defaultValue: defaultValue, _, _, _):
			string = "Float(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .doubleTweak(value: value, defaultValue: defaultValue, _, _, _):
			string = "Double(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .color(value: value, defaultValue: defaultValue):
			string = "Color(\(value.hexString), alpha: \(value.alphaValue))"
			differsFromDefault = (value != defaultValue)
		}
		return (string, differsFromDefault)
	}

	private var isSignedNumberType: Bool {
		switch self {
		case .integer, .float, .doubleTweak:
			return true
		case .boolean, .color:
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
		case .boolean, .color:
			return nil

		case let .integer(intValue, intDefaultValue, intMin, intMax, _):
			currentValue = Double(intValue)
			defaultValue = Double(intDefaultValue)
			minimum = intMin.map(Double.init)
			maximum = intMax.map(Double.init)

		case let .float(floatValue, floatDefaultValue, floatMin, floatMax, _):
			currentValue = Double(floatValue)
			defaultValue = Double(floatDefaultValue)
			minimum = floatMin.map(Double.init)
			maximum = floatMax.map(Double.init)

		case let .doubleTweak(doubleValue, doubleDefaultValue, doubleMin, doubleMax, _):
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
