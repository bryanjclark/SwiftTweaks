//
//  Precision+TweaksTests.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/12/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import XCTest

private struct PrecisionTestCaseCGFloat{
	let inputValue: CGFloat
	let precision: PrecisionLevel
	let expectedValue: CGFloat

	init(_ inputValue: CGFloat, _ precision: PrecisionLevel, _ expectedValue: CGFloat) {
		self.inputValue = inputValue
		self.precision = precision
		self.expectedValue = expectedValue
	}

	static func confirmTest(testCase: PrecisionTestCaseCGFloat) {
		let roundedValue = testCase.inputValue.roundToNearest(testCase.precision)
		let areTheyWithinEpsilon = fabs(testCase.expectedValue - roundedValue) < CGFloat(FLT_EPSILON)
		XCTAssertTrue(areTheyWithinEpsilon, "Precision failed for \(testCase.inputValue) rounding to nearest \(testCase.precision)")
	}
}

private struct PrecisionTestCaseDouble{
	let inputValue: Double
	let precision: PrecisionLevel
	let expectedValue: Double

	init(_ inputValue: Double, _ precision: PrecisionLevel, _ expectedValue: Double) {
		self.inputValue = inputValue
		self.precision = precision
		self.expectedValue = expectedValue
	}

	static func confirmTest(testCase: PrecisionTestCaseDouble) {
		let roundedValue = testCase.inputValue.roundToNearest(testCase.precision)
		let areTheyWithinEpsilon = fabs(testCase.expectedValue - roundedValue) < DBL_EPSILON
		XCTAssertTrue(areTheyWithinEpsilon, "Precision failed for \(testCase.inputValue) rounding to nearest \(testCase.precision)")
	}
}

class Precision_TweaksTests: XCTestCase {
	func testPrecisionCGFloat() {
		[
			PrecisionTestCaseCGFloat(0.1, .Integer, 0),
			PrecisionTestCaseCGFloat(0.5, .Integer, 1),
			PrecisionTestCaseCGFloat(0.00001, .Thousandth, 0),
			PrecisionTestCaseCGFloat(0.0001, .Thousandth, 0),
			PrecisionTestCaseCGFloat(0.001, .Thousandth, 0.001),
			PrecisionTestCaseCGFloat(0.01, .Tenth, 0),
			PrecisionTestCaseCGFloat(0.1, .Integer, 0),

			PrecisionTestCaseCGFloat(0.55, .Integer, 1),
			PrecisionTestCaseCGFloat(0.55, .Tenth, 0.6),
			PrecisionTestCaseCGFloat(0.4445, .Thousandth, 0.445),

			PrecisionTestCaseCGFloat(0.49999999, .Thousandth, 0.500),
			PrecisionTestCaseCGFloat(0.4999, .Thousandth, 0.500),
			PrecisionTestCaseCGFloat(0.499, .Thousandth, 0.499),
			PrecisionTestCaseCGFloat(0.499, .Hundredth, 0.50),
			PrecisionTestCaseCGFloat(0.499, .Tenth, 0.5),
			PrecisionTestCaseCGFloat(0.499, .Integer, 0),
		].forEach(PrecisionTestCaseCGFloat.confirmTest)
	}

	func testPrecisionDouble() {
		[
			PrecisionTestCaseDouble(0.1, .Integer, 0),
			PrecisionTestCaseDouble(0.5, .Integer, 1),
			PrecisionTestCaseDouble(0.00001, .Thousandth, 0),
			PrecisionTestCaseDouble(0.0001, .Thousandth, 0),
			PrecisionTestCaseDouble(0.001, .Thousandth, 0.001),
			PrecisionTestCaseDouble(0.01, .Tenth, 0),
			PrecisionTestCaseDouble(0.1, .Integer, 0),

			PrecisionTestCaseDouble(0.55, .Integer, 1),
			PrecisionTestCaseDouble(0.55, .Tenth, 0.6),
			PrecisionTestCaseDouble(0.4445, .Thousandth, 0.445),

			PrecisionTestCaseDouble(0.49999999, .Thousandth, 0.500),
			PrecisionTestCaseDouble(0.4999, .Thousandth, 0.500),
			PrecisionTestCaseDouble(0.499, .Thousandth, 0.499),
			PrecisionTestCaseDouble(0.499, .Hundredth, 0.50),
			PrecisionTestCaseDouble(0.499, .Tenth, 0.5),
			PrecisionTestCaseDouble(0.499, .Integer, 0),
			].forEach(PrecisionTestCaseDouble.confirmTest)
	}
}