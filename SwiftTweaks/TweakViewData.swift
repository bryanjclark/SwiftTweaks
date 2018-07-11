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
	case string(value: String, defaultValue: String)
	case stringList(value: StringOption, defaultValue: StringOption, options: [StringOption])
	case action(value: TweakAction)

	init<T: TweakableType>(type: TweakViewDataType, value: T, defaultValue: T, minimum: T?, maximum: T?, stepSize: T?, options: [T]?) {
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
		case .string:
			self = .string(value: value as! String, defaultValue: defaultValue as! String)
		case .stringList:
			self = .stringList(value: value as! StringOption, defaultValue: defaultValue as! StringOption, options: options!.map { $0 as! StringOption })
		case .action:
			self = .action(value: value as! TweakAction)
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
		case let .string(stringValue, _):
			return stringValue
		case let .stringList(value: stringValue, _, _):
			return stringValue
		case let .action(value: value):
			return value
		}
	}

	/// For signedNumberType tweaks, this is a shortcut to `value` as a Double
	var doubleValue: Double? {
		switch self {
		case .boolean, .color, .action, .string, .stringList:
			return nil
		case let .integer(value: intValue, _, _, _, _):
			return Double(intValue)
		case let .float(value: floatValue, _, _, _, _):
			return Double(floatValue)
		case let .doubleTweak(value: doubleValue, _, _, _, _):
			return doubleValue
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
		case let .string(value, defaultValue):
			string = value
			differsFromDefault = (value != defaultValue)
		case let .stringList(value: value, defaultValue: defaultValue, _):
			string = value.value
			differsFromDefault = string != defaultValue.value
		case .action:
			string = ""
			differsFromDefault = false
		}
		return (string, differsFromDefault)
	}

	private var isSignedNumberType: Bool {
		switch self {
		case .integer, .float, .doubleTweak:
			return true
		case .boolean, .color, .action, .string, .stringList:
			return false
		}
	}

	// These are the defaults that UIKit has for the UIStepper min and max
	internal static let stepperDefaultMinimum: Double = 0

	internal static let stepperDefaultStepSizeLarge: Double = 1
	internal static let stepperDefaultMaximumLarge: Double = 100

	internal static let stepperDefaultStepSizeSmall: Double = 0.01
	internal static let stepperDefaultMaximumSmall: Double = 1

	/// Used when no max is given and the default is > stepperDefaultMaximum
	internal static let stepperBoundsMultiplier: Double = 2

	/// Represents the configuration for a UIStepper's min/max/stepSize values
	internal typealias StepperValues = (stepperMin: Double, stepperMax: Double, stepSize: Double)

	/// UISteppers *require* a maximum value (ugh) and they default to 100 (ughhhh)
	/// Since UIKit requires that we provide max/min/stepSize stuff, let's try to choose reasonable values.
	/// This procedure:
	///  - Uses (min = 0, max = 10, stepSize = 0.01) for non-integer tweaks where the default value is smaller than 1 and max is <= 1 if it exists.
	///  - Defaults to (min = 0, max = 100, and stepSize = 1) for other tweaks
	///  - Adjusts the (min = 0, max = 100) bit for tweaks that are (< 0) or (> 100)
	///
	/// Of course, the actual min/max are enforced by the Tweak's definition,
	/// so the user can create/enforce their own min/max by typing in the value into the UI
	/// or by adjusting the Tweak definition to include exact min/max/step preferences.
	var stepperValues: StepperValues? {
		precondition(self.isSignedNumberType)

		let currentValue: Double
		let defaultValue: Double
		let minimum: Double?
		let maximum: Double?
		let step: Double?
		let isInteger: Bool
		switch self {
		case .boolean, .color, .action, .stringList, .string:
			return nil

		case let .integer(intValue, intDefaultValue, intMin, intMax, intStep):
			currentValue = Double(intValue)
			defaultValue = Double(intDefaultValue)
			minimum = intMin.map(Double.init)
			maximum = intMax.map(Double.init)
			step = intStep.map(Double.init)
			isInteger = true

		case let .float(floatValue, floatDefaultValue, floatMin, floatMax, floatStep):
			currentValue = Double(floatValue)
			defaultValue = Double(floatDefaultValue)
			minimum = floatMin.map(Double.init)
			maximum = floatMax.map(Double.init)
			step = floatStep.map(Double.init)
			isInteger = false

		case let .doubleTweak(doubleValue, doubleDefaultValue, doubleMin, doubleMax, doubleStep):
			currentValue = doubleValue
			defaultValue = doubleDefaultValue
			minimum = doubleMin
			maximum = doubleMax
			step = doubleStep
			isInteger = false
		}

		// UIStepper defaults to (min = 0, max = 100, step = 1), so we'll use those as a fallback.
		var resultMin: Double = TweakViewData.stepperDefaultMinimum
		var resultMax: Double = TweakViewData.stepperDefaultMaximumLarge
		var resultStep: Double = TweakViewData.stepperDefaultStepSizeLarge

		// We'll use the "small defaults" when all of these conditions are met:
		//  - non-integer
		//  - defaultValue 0 < x < 1
		//  - currentValue 0 < x < 1
		//  - maxValue (if given) <= 1
		let isSmallDefaultValue = (0 <= defaultValue) && (defaultValue < TweakViewData.stepperDefaultMaximumSmall)
		let isSmallCurrentValue = (0 <= currentValue) && (currentValue < TweakViewData.stepperDefaultMaximumSmall)
		let isSmallMaxValue = (maximum ?? 0) <= TweakViewData.stepperDefaultMaximumSmall
		if !isInteger && isSmallDefaultValue && isSmallMaxValue && isSmallCurrentValue {
			resultMax = TweakViewData.stepperDefaultMaximumSmall
			resultStep = TweakViewData.stepperDefaultStepSizeSmall

		} else {
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
		}

		// If the tweak is an integer, whatever we've got, let's round it to the nearest integer.
		if isInteger {
			resultMin = resultMin.roundToNearest(.integer)
			resultMax = resultMax.roundToNearest(.integer)
			resultStep = resultStep.roundToNearest(.integer)
		}

		// Lastly, to override any above work: if an explicit min/max/step were given, use those.
		resultMin = minimum ?? resultMin
		resultMax = maximum ?? resultMax
		resultStep = step ?? resultStep

		return (resultMin, resultMax, resultStep)
	}
}
