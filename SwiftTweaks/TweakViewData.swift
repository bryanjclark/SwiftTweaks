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
	case int8(value: Int8, defaultValue: Int8, min: Int8?, max: Int8?, stepSize: Int8?)
	case int16(value: Int16, defaultValue: Int16, min: Int16?, max: Int16?, stepSize: Int16?)
	case int32(value: Int32, defaultValue: Int32, min: Int32?, max: Int32?, stepSize: Int32?)
	case int64(value: Int64, defaultValue: Int64, min: Int64?, max: Int64?, stepSize: Int64?)
	case uInt8(value: UInt8, defaultValue: UInt8, min: UInt8?, max: UInt8?, stepSize: UInt8?)
	case uInt16(value: UInt16, defaultValue: UInt16, min: UInt16?, max: UInt16?, stepSize: UInt16?)
	case uInt32(value: UInt32, defaultValue: UInt32, min: UInt32?, max: UInt32?, stepSize: UInt32?)
	case uInt64(value: UInt64, defaultValue: UInt64, min: UInt64?, max: UInt64?, stepSize: UInt64?)
	case float(value: CGFloat, defaultValue: CGFloat, min: CGFloat?, max: CGFloat?, stepSize: CGFloat?)
	case doubleTweak(value: Double, defaultValue: Double, min: Double?, max: Double?, stepSize: Double?)
	case color(value: UIColor, defaultValue: UIColor)
	case string(value: String, defaultValue: String)
	case date(value: Date, defaultValue: Date)
	case stringList(value: StringOption, defaultValue: StringOption, options: [StringOption])
	case action(value: TweakAction)

	init<T: TweakableType>(type: TweakViewDataType, value: T, defaultValue: T, minimum: T?, maximum: T?, stepSize: T?, options: [T]?) {
		switch type {
		case .boolean:
			self = .boolean(value: value as! Bool, defaultValue: defaultValue as! Bool)
		case .uiColor:
			self = .color(value: value as! UIColor, defaultValue: defaultValue as! UIColor)
		case .int8:
			let clippedValue = clip(value as! Int8, minimum as? Int8, maximum as? Int8)
			self = .int8(value: clippedValue, defaultValue: defaultValue as! Int8, min: minimum as? Int8, max: maximum as? Int8, stepSize: stepSize as? Int8)
		case .int16:
			let clippedValue = clip(value as! Int16, minimum as? Int16, maximum as? Int16)
			self = .int16(value: clippedValue, defaultValue: defaultValue as! Int16, min: minimum as? Int16, max: maximum as? Int16, stepSize: stepSize as? Int16)
		case .int32:
			let clippedValue = clip(value as! Int32, minimum as? Int32, maximum as? Int32)
			self = .int32(value: clippedValue, defaultValue: defaultValue as! Int32, min: minimum as? Int32, max: maximum as? Int32, stepSize: stepSize as? Int32)
		case .int64:
			let clippedValue = clip(value as! Int64, minimum as? Int64, maximum as? Int64)
			self = .int64(value: clippedValue, defaultValue: defaultValue as! Int64, min: minimum as? Int64, max: maximum as? Int64, stepSize: stepSize as? Int64)
		case .uInt8:
			let clippedValue = clip(value as! UInt8, minimum as? UInt8, maximum as? UInt8)
			self = .uInt8(value: clippedValue, defaultValue: defaultValue as! UInt8, min: minimum as? UInt8, max: maximum as? UInt8, stepSize: stepSize as? UInt8)
		case .uInt16:
			let clippedValue = clip(value as! UInt16, minimum as? UInt16, maximum as? UInt16)
			self = .uInt16(value: clippedValue, defaultValue: defaultValue as! UInt16, min: minimum as? UInt16, max: maximum as? UInt16, stepSize: stepSize as? UInt16)
		case .uInt32:
			let clippedValue = clip(value as! UInt32, minimum as? UInt32, maximum as? UInt32)
			self = .uInt32(value: clippedValue, defaultValue: defaultValue as! UInt32, min: minimum as? UInt32, max: maximum as? UInt32, stepSize: stepSize as? UInt32)
		case .uInt64:
			let clippedValue = clip(value as! UInt64, minimum as? UInt64, maximum as? UInt64)
			self = .uInt64(value: clippedValue, defaultValue: defaultValue as! UInt64, min: minimum as? UInt64, max: maximum as? UInt64, stepSize: stepSize as? UInt64)
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
		case .date:
			self = .date(value: value as! Date, defaultValue: defaultValue as! Date)
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
		case let .int8(value: intValue, _, _, _, _):
			return intValue
		case let .int16(value: intValue, _, _, _, _):
			return intValue
		case let .int32(value: intValue, _, _, _, _):
			return intValue
		case let .int64(value: intValue, _, _, _, _):
			return intValue
		case let .uInt8(value: intValue, _, _, _, _):
			return intValue
		case let .uInt16(value: intValue, _, _, _, _):
			return intValue
		case let .uInt32(value: intValue, _, _, _, _):
			return intValue
		case let .uInt64(value: intValue, _, _, _, _):
			return intValue
		case let .float(value: floatValue, _, _, _, _):
			return floatValue
		case let .doubleTweak(value: doubleValue, _, _, _, _):
			return doubleValue
		case let .color(value: colorValue, defaultValue: _):
			return colorValue
		case let .date(dateValue, _):
			return dateValue
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
		case .boolean, .color, .action, .string, .stringList, .date:
			return nil
		case let .integer(value: intValue, _, _, _, _):
			return Double(intValue)
		case let .int8(value: intValue, _, _, _, _):
			return Double(intValue)
		case let .int16(value: intValue, _, _, _, _):
			return Double(intValue)
		case let .int32(value: intValue, _, _, _, _):
			return Double(intValue)
		case let .int64(value: intValue, _, _, _, _):
			return Double(intValue)
		case let .uInt8(value: intValue, _, _, _, _):
			return Double(intValue)
		case let .uInt16(value: intValue, _, _, _, _):
			return Double(intValue)
		case let .uInt32(value: intValue, _, _, _, _):
			return Double(intValue)
		case let .uInt64(value: intValue, _, _, _, _):
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
		case let .int8(value: value, defaultValue: defaultValue, _, _, _):
			string = "Int8(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .int16(value: value, defaultValue: defaultValue, _, _, _):
			string = "Int16(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .int32(value: value, defaultValue: defaultValue, _, _, _):
			string = "Int32(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .int64(value: value, defaultValue: defaultValue, _, _, _):
			string = "Int64(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .uInt8(value: value, defaultValue: defaultValue, _, _, _):
			string = "UInt8(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .uInt16(value: value, defaultValue: defaultValue, _, _, _):
			string = "UInt16(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .uInt32(value: value, defaultValue: defaultValue, _, _, _):
			string = "UInt32(\(value))"
			differsFromDefault = (value != defaultValue)
		case let .uInt64(value: value, defaultValue: defaultValue, _, _, _):
			string = "UInt64(\(value))"
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
		case let .date(value, defaultValue):
			string = "\(value)"
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
		case .integer, .int8, .int16, .int32, .int64, .uInt8, .uInt16, .uInt32, .uInt64, .float, .doubleTweak: // XXX not really signed?
			return true
		case .boolean, .color, .action, .string, .stringList, .date:
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
		case .boolean, .color, .action, .stringList, .string, .date:
			return nil

		case let .integer(intValue, intDefaultValue, intMin, intMax, intStep):
			currentValue = Double(intValue)
			defaultValue = Double(intDefaultValue)
			minimum = intMin.map(Double.init)
			maximum = intMax.map(Double.init)
			step = intStep.map(Double.init)
			isInteger = true

		case let .int8(intValue, intDefaultValue, intMin, intMax, intStep):
			currentValue = Double(intValue)
			defaultValue = Double(intDefaultValue)
			minimum = intMin.map(Double.init)
			maximum = intMax.map(Double.init)
			step = intStep.map(Double.init)
			isInteger = true

		case let .int16(intValue, intDefaultValue, intMin, intMax, intStep):
			currentValue = Double(intValue)
			defaultValue = Double(intDefaultValue)
			minimum = intMin.map(Double.init)
			maximum = intMax.map(Double.init)
			step = intStep.map(Double.init)
			isInteger = true

		case let .int32(intValue, intDefaultValue, intMin, intMax, intStep):
			currentValue = Double(intValue)
			defaultValue = Double(intDefaultValue)
			minimum = intMin.map(Double.init)
			maximum = intMax.map(Double.init)
			step = intStep.map(Double.init)
			isInteger = true

		case let .int64(intValue, intDefaultValue, intMin, intMax, intStep):
			currentValue = Double(intValue)
			defaultValue = Double(intDefaultValue)
			minimum = intMin.map(Double.init)
			maximum = intMax.map(Double.init)
			step = intStep.map(Double.init)
			isInteger = true

		case let .uInt8(intValue, intDefaultValue, intMin, intMax, intStep):
			currentValue = Double(intValue)
			defaultValue = Double(intDefaultValue)
			minimum = intMin.map(Double.init)
			maximum = intMax.map(Double.init)
			step = intStep.map(Double.init)
			isInteger = true

		case let .uInt16(intValue, intDefaultValue, intMin, intMax, intStep):
			currentValue = Double(intValue)
			defaultValue = Double(intDefaultValue)
			minimum = intMin.map(Double.init)
			maximum = intMax.map(Double.init)
			step = intStep.map(Double.init)
			isInteger = true

		case let .uInt32(intValue, intDefaultValue, intMin, intMax, intStep):
			currentValue = Double(intValue)
			defaultValue = Double(intDefaultValue)
			minimum = intMin.map(Double.init)
			maximum = intMax.map(Double.init)
			step = intStep.map(Double.init)
			isInteger = true

		case let .uInt64(intValue, intDefaultValue, intMin, intMax, intStep):
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
