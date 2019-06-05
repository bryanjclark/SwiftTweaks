//
//  UIColor+Tweaks.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/16/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

// info via http://arstechnica.com/apple/2009/02/iphone-development-accessing-uicolor-components/

internal extension UIColor {

	/// Creates a UIColor with a given hex string (e.g. "#FF00FF")
	// NOTE: Would use a failable init (e.g. `UIColor(hexString: _)` but have to wait until Swift 2.2.1 https://github.com/Khan/SwiftTweaks/issues/38
	static func colorWithHexString(_ hexString: String) -> UIColor? {
		// Strip whitespace, "#", "0x", and make uppercase
		let hexString = hexString
			.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
			.trimmingCharacters(in: NSCharacterSet(charactersIn: "#") as CharacterSet)
            .replacingOccurrences(of: "0x", with: "")
			.uppercased()

		// We should have 6 or 8 characters now.
		let hexStringLength = hexString.count
		if (hexStringLength != 6) && (hexStringLength != 8) {
			return nil
		}

		// Break the string into its components
		let hexStringContainsAlpha = (hexStringLength == 8)
		let colorStrings: [Substring] = [
			hexString[hexString.startIndex...hexString.index(hexString.startIndex, offsetBy: 1)],
			hexString[hexString.index(hexString.startIndex, offsetBy: 2)...hexString.index(hexString.startIndex, offsetBy: 3)],
			hexString[hexString.index(hexString.startIndex, offsetBy: 4)...hexString.index(hexString.startIndex, offsetBy: 5)],
			hexStringContainsAlpha ? hexString[hexString.index(hexString.startIndex, offsetBy: 6)...hexString.index(hexString.startIndex, offsetBy: 7)] : "FF"
		]

		// Convert string components into their CGFloat (r,g,b,a) components
		let colorFloats: [CGFloat] = colorStrings.map {
			var componentInt: CUnsignedInt = 0
			Scanner(string: String($0)).scanHexInt32(&componentInt)
			return CGFloat(componentInt) / CGFloat(255.0)
		}

		return UIColor(red: colorFloats[0], green: colorFloats[1], blue: colorFloats[2], alpha: colorFloats[3])
	}

	convenience init(hex: UInt32, alpha: CGFloat = 1) {
		self.init(
			red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat((hex & 0x0000FF)) / 255.0,
			alpha: alpha
		)
	}

	var alphaValue: CGFloat {
		var white: CGFloat = 0
		var alpha: CGFloat = 0
		getWhite(&white, alpha: &alpha)
		return alpha
	}

	var hexString: String {
		assert(canProvideRGBComponents, "Must be an RGB color to use UIColor.hexValue")

		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		getRed(&red, green: &green, blue: &blue, alpha: &alpha)

		return String(format: "#%02x%02x%02x", arguments: [
			Int(red * 255.0),
			Int(green * 255.0),
			Int(blue * 255.0)
			]).uppercased()
	}

	private var canProvideRGBComponents: Bool {
		switch self.cgColor.colorSpace!.model {
		case .rgb, .monochrome:
			return true
		default:
			return false
		}
	}
}
