//
//  Tweak+TweaksTests.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/7/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import XCTest
@testable import SwiftTweaks

private struct ClippingTweakTestCase<T> where T: SignedNumeric, T: Comparable, T: TweakableType {
	let defaultValue: T
	let min: T?
	let max: T?
	let expected: T

	static func verify(_ testCase: ClippingTweakTestCase) {
		let tweak: Tweak<T> = Tweak(collectionName: "a", groupName: "b", tweakName: "c",
		                            defaultValue: testCase.defaultValue,
		                            minimumValue: testCase.min,
		                            maximumValue: testCase.max,
		                            stepSize: nil
		)
		XCTAssertEqual(testCase.expected, tweak.defaultValue)

		if let min = testCase.min {
			XCTAssertGreaterThanOrEqual(testCase.defaultValue, min)
		}

		if let max = testCase.max {
			XCTAssertLessThanOrEqual(testCase.defaultValue, max)
		}
	}
}

class Tweaks_TweaksTest: XCTestCase {

	func testTweakClipping() {
		[
			ClippingTweakTestCase(defaultValue: 10, min: nil, max: nil, expected: 10),
			ClippingTweakTestCase(defaultValue: 10, min: nil, max: 100, expected: 10),
			ClippingTweakTestCase(defaultValue: 10, min: 0, max: nil, expected: 10),

			ClippingTweakTestCase(defaultValue: -10, min: nil, max: nil, expected: -10),
			ClippingTweakTestCase(defaultValue: -10, min: nil, max: 0, expected: -10),
			ClippingTweakTestCase(defaultValue: -10, min: -100, max: nil, expected: -10),

			ClippingTweakTestCase(defaultValue: 10, min: 0, max: 100, expected: 10),
			ClippingTweakTestCase(defaultValue: 10, min: -100, max: 100, expected: 10),
			ClippingTweakTestCase(defaultValue: 10, min: 10, max: 100, expected: 10),
			].forEach(ClippingTweakTestCase.verify)

		/* NOTE: I'd love to test these - but we can't simultaneously have:
		- crashing-inits for Tweak<T> *and*
		- unit tests for clipping Tweaks
		...so, until we have `XCTAssertCrash` or something like that, we can't test the following:

		ClippingTweakTestCase(defaultValue: 10, min: 20, max: 100, expected: 20),	// should crash
		ClippingTweakTestCase(defaultValue: 100, min: 0, max: 90, expected: 90),		// should crash
		ClippingTweakTestCase(defaultValue: 10, min: 20, max: 100, expected: 20),	// should crash
		*/
	}
}
