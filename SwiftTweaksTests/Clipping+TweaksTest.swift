//
//  Clipping+TweaksTest.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/7/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import XCTest

private struct ClippingTestCase<T> where T: SignedNumber {
	let inputValue: T
	let min: T?
	let max: T?
	let expected: T

	static func confirmTest(_ testCase: ClippingTestCase) {
		let clipped = clip(testCase.inputValue, testCase.min, testCase.max)

		XCTAssertEqual(testCase.expected, clipped)

		if let min = testCase.min {
			XCTAssertGreaterThanOrEqual(clipped, min)
		}

		if let max = testCase.max {
			XCTAssertLessThanOrEqual(clipped, max)
		}
	}
}

private struct StepperTestCase {
	let currentValue: Double
	let defaultValue: Double
	let min: Double?
	let max: Double?
	let expected: (expectedMin: Double, expectedMax: Double)

	init(current currentValue: Double, def defaultValue: Double, min: Double?, max: Double?, expected: (Double, Double)) {
		self.currentValue = currentValue
		self.defaultValue = defaultValue
		self.min = min
		self.max = max
		self.expected = expected
	}

	static func confirmTest(_ testCase: StepperTestCase) {
		let tweakViewData = TweakViewData.doubleTweak(
			value: testCase.currentValue,
			defaultValue: testCase.defaultValue,
			min: testCase.min,
			max: testCase.max,
			stepSize: nil
		)

		let (derivedMin, derivedMax) = tweakViewData.stepperLimits!
		let (expectedMin, expectedMax) = testCase.expected
		XCTAssertEqual(derivedMin, expectedMin, "Derived minimum didn't match expected.")
		XCTAssertEqual(derivedMax, expectedMax, "Derived maximum didn't match expected.")
	}
}

class Clipping_TweaksTests: XCTestCase {
	func testClipping() {
		[
			ClippingTestCase(inputValue: 10, min: nil, max: nil, expected: 10),
			ClippingTestCase(inputValue: 10, min: nil, max: 100, expected: 10),
			ClippingTestCase(inputValue: 10, min: 0, max: nil, expected: 10),

			ClippingTestCase(inputValue: -10, min: nil, max: nil, expected: -10),
			ClippingTestCase(inputValue: -10, min: nil, max: 0, expected: -10),
			ClippingTestCase(inputValue: -10, min: -100, max: nil, expected: -10),

			ClippingTestCase(inputValue: 10, min: 0, max: 100, expected: 10),
			ClippingTestCase(inputValue: 10, min: -100, max: 100, expected: 10),
			ClippingTestCase(inputValue: 10, min: 10, max: 100, expected: 10),

			ClippingTestCase(inputValue: 10, min: 20, max: 100, expected: 20),
			ClippingTestCase(inputValue: 100, min: 0, max: 90, expected: 90),
			ClippingTestCase(inputValue: 10, min: 20, max: 100, expected: 20),
		].forEach(ClippingTestCase.confirmTest)
	}

	func testStepperLimits() {
		let defaultMin = TweakViewData.stepperDefaultMinimum
		let defaultMax = TweakViewData.stepperDefaultMaximum
		let defaultBounds = (defaultMin, defaultMax)
		let boundsMultiplier = TweakViewData.stepperBoundsMultiplier
		[
			StepperTestCase(current: 10, def: 10, min: nil, max: nil, expected: defaultBounds),

			StepperTestCase(current: 10, def: 40, min: nil, max: nil, expected: defaultBounds),
			StepperTestCase(current: 40, def: 10, min: nil, max: nil, expected: defaultBounds),

			StepperTestCase(current: 50, def: 101, min: nil, max: nil, expected: (defaultMin, 101 * boundsMultiplier)),
			StepperTestCase(current: -10, def: -1, min: nil, max: nil, expected: (-10 * boundsMultiplier, defaultMax)),
			StepperTestCase(current: 165, def: 165, min: nil, max: nil, expected: (defaultMin, 165 * boundsMultiplier)),
			StepperTestCase(current: 60, def: -20, min: nil, max: nil, expected: (-20 * boundsMultiplier, defaultMax)),

			StepperTestCase(current: -30, def: -40, min: -100, max: 0, expected: (-100, 0)),
			StepperTestCase(current: 600, def: 500, min: 400, max: 1000, expected: (400, 1000)),

			StepperTestCase(current: 400, def: 200, min: nil, max: nil, expected: (defaultMin, 400 * boundsMultiplier)),
		].forEach(StepperTestCase.confirmTest)
	}
}
