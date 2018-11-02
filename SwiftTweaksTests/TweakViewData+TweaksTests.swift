//
//  TweakViewData+TweaksTests.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 10/6/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import XCTest

class TweakViewData_TweaksTests: XCTestCase {

	private struct StepperTestCase {
		let defaultValue: Double
		let currentValue: Double
		let customMin: Double?
		let customMax: Double?
		let customStep: Double?
		let expectedStep: Double?
		let expectedBounds: (Double, Double)?

		var intTweakViewData: TweakViewData {
			return .integer(
				value: Int(currentValue),
				defaultValue: Int(defaultValue),
				min: customMin.map(Int.init),
				max: customMax.map(Int.init),
				stepSize: customStep.map(Int.init)
			)
		}

		var floatTweakViewData: TweakViewData {
			return .float(
				value: CGFloat(currentValue),
				defaultValue: CGFloat(defaultValue),
				min: customMin.map { CGFloat.init($0) },
				max: customMax.map { CGFloat.init($0) },
				stepSize: customStep.map { CGFloat.init($0) }
			)
		}

		var doubleTweakViewData: TweakViewData {
			return .doubleTweak(
				value: currentValue,
				defaultValue: defaultValue,
				min: customMin,
				max: customMax,
				stepSize: customStep
			)
		}

		static func verifyNonIntegerStepSizeForTestCase(testCase: StepperTestCase) {
			let floatStepSize = testCase.floatTweakViewData.stepperValues!.stepSize
			XCTAssertEqual(
				floatStepSize,
				testCase.expectedStep!,
				accuracy: .ulpOfOne
			)

			let doubleStepSize = testCase.doubleTweakViewData.stepperValues!.stepSize
			XCTAssertEqual(
				doubleStepSize,
				testCase.expectedStep!,
				accuracy: .ulpOfOne
			)
		}

		static func verifyIntegerStepSizeForTestCase(testCase: StepperTestCase) {
			let intStepSize = testCase.intTweakViewData.stepperValues!.stepSize
			XCTAssertEqual(Int(intStepSize), Int(testCase.expectedStep!))
		}

		static func verifyStepperBoundsTestCase(testCase: StepperTestCase) {
			XCTAssertEqual(
				testCase.expectedBounds!.0,
				testCase.floatTweakViewData.stepperValues!.stepperMin,
				accuracy: .ulpOfOne
			)

			XCTAssertEqual(
				testCase.expectedBounds!.1,
				testCase.floatTweakViewData.stepperValues!.stepperMax,
				accuracy: .ulpOfOne
			)

			XCTAssertEqual(
				testCase.expectedBounds!.0,
				testCase.doubleTweakViewData.stepperValues!.stepperMin,
				accuracy: .ulpOfOne
			)

			XCTAssertEqual(
				testCase.expectedBounds!.1,
				testCase.doubleTweakViewData.stepperValues!.stepperMax,
				accuracy: .ulpOfOne
			)
		}
	}

	func testNonIntegerStepSize() {
		let tests: [(defaultValue: Double, customMin: Double?, customMax: Double?, customStep: Double?, expectedStep: Double)] = [
			(0,		nil, nil, nil,		0.01),
			(0.5,	nil, nil, nil,		0.01),
			(0.01,  nil, nil, nil,		0.01),
			(100,	nil, nil, nil,		1),
			(10,	nil, nil, nil,		1),
			(2,		nil, nil, nil,		1),
			(1.01,	nil, nil, nil,		1),

			(0,		0, 100, nil,			1),
			(0,		0, 10, nil,			1),
			(0,	    0, 0.1, nil,			0.01),
			(10,	0, 10, nil,			1),


			(0.5,	nil, nil, 0.5,		0.5),
			(1.0,	nil, nil, 0.1,		0.1),
			(10,	10, 20, 5,			5),
		]

		tests
			.map { StepperTestCase(
				defaultValue: $0,
				currentValue: $0, // NOTE: We don't currently care about currentValue for stepSize calculations.
				customMin: $1,
				customMax: $2,
				customStep: $3,
				expectedStep: $4,
				expectedBounds: nil)
			}
			.forEach(StepperTestCase.verifyNonIntegerStepSizeForTestCase)
	}

	func testIntegerStepSize() {
		let tests: [(defaultValue: Int, customMin: Int?, customMax: Int?, customStep: Int?, expectedStep: Int)] = [
			(0,		nil, nil, nil,		1),
			(1,		nil, nil, nil,		1),
			(2,		nil, nil, nil,		1),
			(100,	nil, nil, nil,		1),
			(10,	nil, nil, nil,		1),


			(0,		0, 100, nil,			1),
			(0,		0, 10, nil,			1),
			(10,	0, 10, nil,			1),

			(1,		nil, nil, 1,			1),
			(1,		nil, nil, 4,			4),
			(10,	10, 20, 5,			5),
			]

		tests
			.map { StepperTestCase(
				defaultValue: Double($0),
				currentValue: Double($0), // NOTE: We don't currently care about currentValue for stepSize calculations.
				customMin: $1.map(Double.init),
				customMax: $2.map(Double.init),
				customStep: $3.map(Double.init),
				expectedStep: Double($4),
				expectedBounds: nil)
			}
			.forEach(StepperTestCase.verifyIntegerStepSizeForTestCase)
	}

	func testStepperLimits() {
		let defaultMin = TweakViewData.stepperDefaultMinimum

		let defaultMaxLarge = TweakViewData.stepperDefaultMaximumLarge
		let defaultBoundsLarge = (defaultMin, defaultMaxLarge)

		let defaultMaxSmall = TweakViewData.stepperDefaultMaximumSmall
		let defaultBoundsSmall = (defaultMin, defaultMaxSmall)

		let boundsMultipler = TweakViewData.stepperBoundsMultiplier

		let tests : [(current: Double, def: Double, min: Double?, max: Double?, expected: (Double, Double))] = [
			(10, 10, nil, nil, defaultBoundsLarge),
			(10, 40, nil, nil, defaultBoundsLarge),
			(40, 10, nil, nil, defaultBoundsLarge),

			(0, 0, nil, nil, defaultBoundsSmall),
			(0.2, 0.3, nil, nil, defaultBoundsSmall),
			(0, 0.05, nil, nil, defaultBoundsSmall),

			(50, 101, nil, nil, (defaultMin, 101 * boundsMultipler)),
			(-10, -1, nil, nil, (-10 * boundsMultipler, defaultMaxLarge)),
			(165, 165, nil, nil, (defaultMin, 165 * boundsMultipler)),
			(60, -20, nil, nil, (-20 * boundsMultipler, defaultMaxLarge)),

			(-30, -40, -100, 0, (-100, 0)),
			(600, 500, 400, 1000, (400, 1000)),
			(400, 200, nil, nil, (defaultMin, 400 * boundsMultipler)),
		]

		tests
			.map { test in
				StepperTestCase(
					defaultValue: test.def,
					currentValue: test.current,
					customMin: test.min,
					customMax: test.max,
					customStep: nil,
					expectedStep: nil,
					expectedBounds: test.expected
				)
			}
			.forEach(StepperTestCase.verifyStepperBoundsTestCase)
	}
}
