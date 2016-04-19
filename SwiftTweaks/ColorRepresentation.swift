//
//  ColorComponents.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/16/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal enum ColorRepresentationType: Int {
	case Hex = 0
	case RGBa = 1
	case HSBa = 2

	static let titles: [String] = ["Hex", "RGBa", "HSBa"]
}

internal enum ColorRepresentation {
	case Hex(hex: String, alpha: ColorComponentNumerical)
	case RGBa(r: ColorComponentNumerical, g: ColorComponentNumerical, b: ColorComponentNumerical, a: ColorComponentNumerical)
	case HSBa(h: ColorComponentNumerical, s: ColorComponentNumerical, b: ColorComponentNumerical, a: ColorComponentNumerical)
}

extension ColorRepresentation {
	var type: ColorRepresentationType {
		switch self {
		case .Hex: return .Hex
		case .RGBa: return .RGBa
		case .HSBa: return .HSBa
		}
	}

	var numberOfComponents: Int {
		switch self {
		case .Hex: return 2
		case .RGBa, .HSBa: return 4
		}
	}

	var color: UIColor {
		switch self {
		case let .Hex(hex: hex, alpha: alpha):
			return UIColor.colorWitHHexString(hex)!.colorWithAlphaComponent(CGFloat(alpha.rawValue))
		case let .RGBa(r: r, g: g, b: b, a: a):
			return UIColor(red: r.rawValue, green: g.rawValue, blue: b.rawValue, alpha: a.rawValue)
		case let .HSBa(h: h, s: s, b: b, a: a):
			return UIColor(hue: h.rawValue, saturation: s.rawValue, brightness: b.rawValue, alpha: a.rawValue)
		}
	}

	init(type: ColorRepresentationType, color: UIColor) {
		switch type {
		case .Hex:
			var white: CGFloat = 0
			var alpha: CGFloat = 0
			color.getWhite(&white, alpha: &alpha)

			self = .Hex(
				hex: color.hexString,
				alpha: ColorComponentNumerical(type: .Alpha, rawValue: alpha)
			)
		case .RGBa:
			var red: CGFloat = 0
			var green: CGFloat = 0
			var blue: CGFloat = 0
			var alpha: CGFloat = 0
			color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

			self = .RGBa(
				r: ColorComponentNumerical(type: .Red, rawValue: red),
				g: ColorComponentNumerical(type: .Green, rawValue: green),
				b: ColorComponentNumerical(type: .Blue, rawValue: blue),
				a: ColorComponentNumerical(type: .Alpha, rawValue: alpha)
			)
		case .HSBa:
			var hue: CGFloat = 0
			var saturation: CGFloat = 0
			var brightness: CGFloat = 0
			var alpha: CGFloat = 0
			color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

			self = .HSBa(
				h: ColorComponentNumerical(type: .Hue, rawValue: hue),
				s: ColorComponentNumerical(type: .Saturation, rawValue: saturation),
				b: ColorComponentNumerical(type: .Brightness, rawValue: brightness),
				a: ColorComponentNumerical(type: .Alpha, rawValue: alpha)
			)
		}
	}

	subscript(index: Int) -> ColorComponent? {
		switch self {
		case let .Hex(hex: hex, alpha: alpha):
			switch index {
			case 0: return .HexComponent(hex)
			case 1: return .NumericalComponent(alpha)
			default: break
			}
		case let .RGBa(r: r, g: g, b: b, a: a):
			switch index {
			case 0: return .NumericalComponent(r)
			case 1: return .NumericalComponent(g)
			case 2: return .NumericalComponent(b)
			case 3: return .NumericalComponent(a)
			default: break
			}
		case let .HSBa(h: h, s: s, b: b, a: a):
			switch index {
			case 0: return .NumericalComponent(h)
			case 1: return .NumericalComponent(s)
			case 2: return .NumericalComponent(b)
			case 3: return .NumericalComponent(a)
			default: break
			}
		}
		return nil
	}
}

/// Represents a component of a ColorRepresentation
internal enum ColorComponent {
	case HexComponent(String) // e.g. #FFFFFF = white
	case NumericalComponent(ColorComponentNumerical) // e.g. RGB, HSB, alpha

	var title: String {
		switch self {
		case .HexComponent:
			return "Hex"
		case .NumericalComponent(let colorComponentNumerical):
			return colorComponentNumerical.title
		}
	}
	
	var numericType: ColorComponentNumericalType? {
		switch self {
		case .NumericalComponent(let numericComponent):
			return numericComponent.type
		case .HexComponent:
			return nil
		}
	}

	var numericValue: ColorComponentNumerical? {
		switch self {
		case .NumericalComponent(let numericComponent):
			return numericComponent
		case .HexComponent:
			return nil
		}
	}
}

/// Represents an instance of a ColorComponent's numerical component.
internal struct ColorComponentNumerical {
	let type: ColorComponentNumericalType
	let value: Float

	var title: String {
		return type.title
	}

	var rawValue: CGFloat {
		return CGFloat(value / type.maximumValue)
	}

	init(type: ColorComponentNumericalType, rawValue: CGFloat) {
		self.type = type
		assert(0.0 <= rawValue && rawValue <= 1.0)

		self.value = Float(rawValue) * type.maximumValue
	}

	init(type: ColorComponentNumericalType, value: Float) {
		self.type = type
		assert(type.minimumValue <= value && value <= type.maximumValue)

		self.value = value
	}
}

/// A list of the types of numerical color components, and describes their behavior.
internal enum ColorComponentNumericalType {
	case Hue
	case Saturation
	case Brightness

	case Red
	case Green
	case Blue

	case Alpha

	var title: String {
		switch self {
		case .Hue: return "H"
		case .Saturation: return "S"
		case .Brightness: return "B"

		case .Red: return "R"
		case .Green: return "G"
		case .Blue: return "B"

		case .Alpha: return "A"
		}
	}

	var minimumValue: Float {
		return 0
	}

	var maximumValue: Float {
		switch self {
		case .Hue:
			return 360
		case .Saturation, .Brightness:
			return 100
		case .Red, .Green, .Blue:
			return 255
		case .Alpha:
			return 1

		}
	}

	var roundsToInteger: Bool {
		switch self {
		case .Hue, .Saturation, .Brightness, .Red, .Green, .Blue:
			return true
		case .Alpha:
			return false
		}
	}

	var tintColor: UIColor? {
		switch self {
		case .Red: return UIColor.redColor()
		case .Green: return UIColor.greenColor()
		case .Blue: return UIColor.blueColor()
		case .Hue, .Saturation, .Brightness, .Alpha: return nil
		}
	}
}