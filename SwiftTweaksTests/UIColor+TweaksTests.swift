//
//  UIColor+TweaksTests.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/20/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import XCTest
@testable import SwiftTweaks

class UIColor_TweaksTests: XCTestCase {


	// MARK: Hex-To-Color

	private struct HexToColorTestCase {
		let string: String
		let expectedColor: UIColor?

		static func verify(_ testCase: HexToColorTestCase) {
			if let generatedColor = UIColor.colorWithHexString(testCase.string) {
				if let expectedColor = testCase.expectedColor {
					XCTAssertEqual(generatedColor.hexString, expectedColor.hexString, "Generated color with hex \(generatedColor.hexString) from test string \(testCase.string), but expected color with hex \(expectedColor.hexString)")
				} else {
					XCTFail("Generated a color from hex string \(testCase.string), but expected no color.")
				}
			} else if let expectedColor = testCase.expectedColor {
				XCTFail("Failed to generate expected color: \(expectedColor.hexString) from hex string \(testCase.string)")
			}
		}
	}

	func testHexToColor() {
		let testCases = [
			HexToColorTestCase(string: "FF0000", expectedColor: UIColor(red: 1, green: 0, blue: 0, alpha: 1)),
			HexToColorTestCase(string: "00FF00", expectedColor: UIColor(red: 0, green: 1, blue: 0, alpha: 1)),
			HexToColorTestCase(string: "0000FF", expectedColor: UIColor(red: 0, green: 0, blue: 1, alpha: 1)),
			HexToColorTestCase(string: "000000", expectedColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1)),
			HexToColorTestCase(string: "FFFFFF", expectedColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1)),
			HexToColorTestCase(string: "FFFF00", expectedColor: UIColor(red: 1, green: 1, blue: 0, alpha: 1)),
			HexToColorTestCase(string: "E6A55E", expectedColor: UIColor(red:0.905, green:0.649, blue:0.369, alpha:1.000)),

			// While we *accept* colors with alpha values in their hex codes, we don't *generate* hexes with alpha.
			HexToColorTestCase(string: "00000000", expectedColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0)),
			HexToColorTestCase(string: "000000FF", expectedColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1)),

			// Invalid strings
			HexToColorTestCase(string: "Hello", expectedColor: nil),
			HexToColorTestCase(string: "blue", expectedColor: nil),
			HexToColorTestCase(string: "", expectedColor: nil),

			// Three-letter test cases (not yet supported, though I'd like them to be someday!)
			HexToColorTestCase(string: "f00", expectedColor: nil),
			HexToColorTestCase(string: "aaa", expectedColor: nil),
			HexToColorTestCase(string: "111", expectedColor: nil),
		]

		testCases.forEach(HexToColorTestCase.verify)

		// Re-run tests, prepending a "#" to each string.
		testCases
			.map { HexToColorTestCase(string: "#"+$0.string, expectedColor: $0.expectedColor) }
			.forEach(HexToColorTestCase.verify)
	}


	// MARK: Color-To-Hex
	private struct ColorToHexTestCase {
		let color: UIColor
		let expectedHex: String

		static func verify(_ testCase: ColorToHexTestCase) {
			XCTAssertEqual(testCase.color.hexString, testCase.expectedHex, "Expected color \(testCase.color) to generate #\(testCase.expectedHex)")
		}
	}

	func testColorToHex() {
		let testCases = [
			ColorToHexTestCase(color: UIColor.red, expectedHex: "#FF0000"),
			ColorToHexTestCase(color: UIColor.green, expectedHex: "#00FF00"),
			ColorToHexTestCase(color: UIColor.blue, expectedHex: "#0000FF"),
			ColorToHexTestCase(color: UIColor.white, expectedHex: "#FFFFFF"),
			ColorToHexTestCase(color: UIColor.black, expectedHex: "#000000"),

			// Our UI ignores the alpha component of a hex code - so we expect a 6-character hex even when alpha's present
			ColorToHexTestCase(color: UIColor.red.withAlphaComponent(0), expectedHex: "#FF0000"),
			ColorToHexTestCase(color: UIColor.black.withAlphaComponent(0.234), expectedHex: "#000000"),
			ColorToHexTestCase(color: UIColor.white.withAlphaComponent(1.0), expectedHex: "#FFFFFF")
		]

		testCases.forEach(ColorToHexTestCase.verify)

	}
}
