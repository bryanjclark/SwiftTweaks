//
//  Precision.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/17/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation
import CoreGraphics

internal enum PrecisionLevel: Int {
	case Integer = 0
	case Tenth = 1
	case Hundredth = 2
	case Thousandth = 3

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
	func roundToNearest(precisionLevel: PrecisionLevel) -> Self
}

extension Roundable {
	func stringValueRoundedToNearest(precisionLevel: PrecisionLevel) -> String {
		let numberFormatter = NSNumberFormatter()
		numberFormatter.maximumFractionDigits = precisionLevel.maximumFractionDigits
		return numberFormatter.stringFromNumber(NSNumber(double: doubleValue))!
	}
}

extension Double: Roundable {
	var doubleValue: Double { return self }

	func roundToNearest(precisionLevel: PrecisionLevel) -> Double {
		// I'd tried using Foundation's NSDecimalNumberHandler, but it wasn't working out as well!
		// This is goofy, but it works:
		// For .Thousandth, multiply times 1000, then round, then divide by 1000. Boom! Rounded to the required precision value.
		return Double(round(doubleValue/precisionLevel.precision))*precisionLevel.precision
	}
}

extension CGFloat: Roundable {
	var doubleValue: Double { return Double(self) }

	func roundToNearest(precisionLevel: PrecisionLevel) -> CGFloat {
		let roundedDouble = Double(self).roundToNearest(precisionLevel)
		return CGFloat(roundedDouble)
	}
}
