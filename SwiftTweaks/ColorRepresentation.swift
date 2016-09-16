//
//  ColorComponents.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/16/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal enum ColorRepresentationType: Int {
	case hex = 0
	case rgBa = 1
	case hsBa = 2

	static let titles: [String] = ["Hex", "RGBa", "HSBa"]
}

internal enum ColorRepresentation {
	case hex(hex: String, alpha: ColorComponentNumerical)
	case rgBa(r: ColorComponentNumerical, g: ColorComponentNumerical, b: ColorComponentNumerical, a: ColorComponentNumerical)
	case hsBa(h: ColorComponentNumerical, s: ColorComponentNumerical, b: ColorComponentNumerical, a: ColorComponentNumerical)
}

extension ColorRepresentation {
	var type: ColorRepresentationType {
		switch self {
		case .hex: return .hex
		case .rgBa: return .rgBa
		case .hsBa: return .hsBa
		}
	}

	var numberOfComponents: Int {
		switch self {
		case .hex: return 2
		case .rgBa, .hsBa: return 4
		}
	}

	var color: UIColor {
		switch self {
		case let .hex(hex: hex, alpha: alpha):
			return UIColor.colorWithHexString(hex)!.withAlphaComponent(CGFloat(alpha.rawValue))
		case let .rgBa(r: r, g: g, b: b, a: a):
			return UIColor(red: r.rawValue, green: g.rawValue, blue: b.rawValue, alpha: a.rawValue)
		case let .hsBa(h: h, s: s, b: b, a: a):
			return UIColor(hue: h.rawValue, saturation: s.rawValue, brightness: b.rawValue, alpha: a.rawValue)
		}
	}

	init(type: ColorRepresentationType, color: UIColor) {
		switch type {
		case .hex:
			var white: CGFloat = 0
			var alpha: CGFloat = 0
			color.getWhite(&white, alpha: &alpha)

			self = .hex(
				hex: color.hexString,
				alpha: ColorComponentNumerical(type: .alpha, rawValue: alpha)
			)
		case .rgBa:
			var red: CGFloat = 0
			var green: CGFloat = 0
			var blue: CGFloat = 0
			var alpha: CGFloat = 0
			color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

			self = .rgBa(
				r: ColorComponentNumerical(type: .red, rawValue: red),
				g: ColorComponentNumerical(type: .green, rawValue: green),
				b: ColorComponentNumerical(type: .blue, rawValue: blue),
				a: ColorComponentNumerical(type: .alpha, rawValue: alpha)
			)
		case .hsBa:
			var hue: CGFloat = 0
			var saturation: CGFloat = 0
			var brightness: CGFloat = 0
			var alpha: CGFloat = 0
			color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

			self = .hsBa(
				h: ColorComponentNumerical(type: .hue, rawValue: hue),
				s: ColorComponentNumerical(type: .saturation, rawValue: saturation),
				b: ColorComponentNumerical(type: .brightness, rawValue: brightness),
				a: ColorComponentNumerical(type: .alpha, rawValue: alpha)
			)
		}
	}

	subscript(index: Int) -> ColorComponent? {
		switch self {
		case let .hex(hex: hex, alpha: alpha):
			switch index {
			case 0: return .hexComponent(hex)
			case 1: return .numericalComponent(alpha)
			default: break
			}
		case let .rgBa(r: r, g: g, b: b, a: a):
			switch index {
			case 0: return .numericalComponent(r)
			case 1: return .numericalComponent(g)
			case 2: return .numericalComponent(b)
			case 3: return .numericalComponent(a)
			default: break
			}
		case let .hsBa(h: h, s: s, b: b, a: a):
			switch index {
			case 0: return .numericalComponent(h)
			case 1: return .numericalComponent(s)
			case 2: return .numericalComponent(b)
			case 3: return .numericalComponent(a)
			default: break
			}
		}
		return nil
	}
}

/// Represents a component of a ColorRepresentation
internal enum ColorComponent {
	case hexComponent(String) // e.g. #FFFFFF = white
	case numericalComponent(ColorComponentNumerical) // e.g. RGB, HSB, alpha

	var title: String {
		switch self {
		case .hexComponent:
			return "Hex"
		case .numericalComponent(let colorComponentNumerical):
			return colorComponentNumerical.title
		}
	}
	
	var numericType: ColorComponentNumericalType? {
		switch self {
		case .numericalComponent(let numericComponent):
			return numericComponent.type
		case .hexComponent:
			return nil
		}
	}

	var numericValue: ColorComponentNumerical? {
		switch self {
		case .numericalComponent(let numericComponent):
			return numericComponent
		case .hexComponent:
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
	case hue
	case saturation
	case brightness

	case red
	case green
	case blue

	case alpha

	var title: String {
		switch self {
		case .hue: return "H"
		case .saturation: return "S"
		case .brightness: return "B"

		case .red: return "R"
		case .green: return "G"
		case .blue: return "B"

		case .alpha: return "A"
		}
	}

	var minimumValue: Float {
		return 0
	}

	var maximumValue: Float {
		switch self {
		case .hue:
			return 360
		case .saturation, .brightness:
			return 100
		case .red, .green, .blue:
			return 255
		case .alpha:
			return 1

		}
	}

	var roundsToInteger: Bool {
		switch self {
		case .hue, .saturation, .brightness, .red, .green, .blue:
			return true
		case .alpha:
			return false
		}
	}

	var tintColor: UIColor? {
		switch self {
		case .red: return UIColor.red
		case .green: return UIColor.green
		case .blue: return UIColor.blue
		case .hue, .saturation, .brightness, .alpha: return nil
		}
	}
}
