//
//  Clipping+TweaksTest.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/7/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import XCTest

private struct ClippingTestCase<T where T: SignedNumberType> {
	let inputValue: T
	let min: T?
	let max: T?
	let expected: T

	static func verify(testCase: ClippingTestCase) {
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

			].forEach(ClippingTestCase.verify)
	}
}