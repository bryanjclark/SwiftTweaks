//
//  Precision.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/17/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation
import CoreGraphics

/// A measure of precision for decimal numbers.
/// The rawValue is the number of decimals, e.g. .Thousandth = 3 for 0.001
internal enum PrecisionLevel: Int {
	case integer = 0
	case tenth = 1
	case hundredth = 2
	case thousandth = 3

	/// The smallest value for the precision - e.g. .Thousandth.multiplier = .001
	var precision: Double {
		return pow(10, -Double(rawValue)) // e.g 10 ^ -3 = 0.001
	}

	/// The number of digits after the decimal for a given precision (e.g. .Thousandth.maximumFractionDigits = 3)
	var maximumFractionDigits: Int {
		return self.rawValue
	}
}

/// Rounds a value within a precision tolerance.
/// Helps to avoid "0.5999999999999" from showing up in yer Tweaks
internal protocol Roundable {
	var doubleValue: Double { get }

	/// Returns the value, rounded to the given precision level.
	func roundToNearest(_ precisionLevel: PrecisionLevel) -> Self
}

extension Roundable {
	func stringValueRoundedToNearest(_ precisionLevel: PrecisionLevel) -> String {
		let numberFormatter = NumberFormatter()
		numberFormatter.maximumFractionDigits = precisionLevel.maximumFractionDigits
        return numberFormatter.string(from: NSNumber(value: doubleValue))!
	}
}

extension Double: Roundable {
	var doubleValue: Double { return self }

	func roundToNearest(_ precisionLevel: PrecisionLevel) -> Double {
		// I'd tried using Foundation's NSDecimalNumberHandler, but it wasn't working out as well!
		// This is goofy, but it works:
		// For .Thousandth, multiply times 1000, then round, then divide by 1000. Boom! Rounded to the required precision value.
        return Double((doubleValue / precisionLevel.precision).rounded()) * precisionLevel.precision
	}
}

extension CGFloat: Roundable {
	var doubleValue: Double { return Double(self) }

	func roundToNearest(_ precisionLevel: PrecisionLevel) -> CGFloat {
		return CGFloat(Double(self).roundToNearest(precisionLevel))
	}
}
