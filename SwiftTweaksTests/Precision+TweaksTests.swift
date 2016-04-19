//
//  Precision+TweaksTests.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/12/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import XCTest

private struct PrecisionTestCase<T: Roundable> {
	let inputValue: T
	let precision: PrecisionLevel
	let expectedValue: T
	let epsilon: T // The allowed error, e.g. Double -> DBL_EPSILON

	init(_ inputValue: T, _ precision: PrecisionLevel, _ expectedValue: T, _ epsilon: T) {
		self.inputValue = inputValue
		self.precision = precision
		self.expectedValue = expectedValue
		self.epsilon = epsilon
	}

	static func verify(testCase: PrecisionTestCase) {
		// Yes, these `doubleValue` bits feel goofy, but they were required to make the compiler happy.
		XCTAssertEqualWithAccuracy(
			testCase.inputValue.roundToNearest(testCase.precision).doubleValue,
			testCase.expectedValue.doubleValue,
			accuracy: testCase.epsilon.doubleValue
		)
	}
}

class Precision_TweaksTests: XCTestCase {
	func testPrecision() {
		let tests: [(Double, PrecisionLevel, Double)] = [
			(0.1, .Integer, 0),
			(0.5, .Integer, 1),
			(0.00001, .Thousandth, 0),
			(0.0001, .Thousandth, 0),
			(0.001, .Thousandth, 0.001),
			(0.01, .Tenth, 0),
			(0.1, .Integer, 0),

			(0.55, .Integer, 1),
			(0.55, .Tenth, 0.6),
			(0.44451, .Thousandth, 0.445),

			(0.49999999, .Thousandth, 0.500),
			(0.4999, .Thousandth, 0.500),
			(0.499, .Thousandth, 0.499),
			(0.499, .Hundredth, 0.50),
			(0.499, .Tenth, 0.5),
			(0.499, .Integer, 0),
		]

		// Double
		tests
			.map { return PrecisionTestCase($0, $1, $2, DBL_EPSILON) }
			.forEach(PrecisionTestCase.verify)

		// CGFloat
		tests
			.map { return PrecisionTestCase(CGFloat($0), $1, CGFloat($2), CGFloat(FLT_EPSILON)) }
			.forEach(PrecisionTestCase.verify)
	}
}