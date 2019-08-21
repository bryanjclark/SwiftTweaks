//
//  TweakableType.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/5/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

/// To add a new <T> to our Tweak<T>, make T conform to this protocol.
public protocol TweakableType {
	static var tweakViewDataType: TweakViewDataType { get }
}

/// The data types that are currently supported for SwiftTweaks.
/// While Tweak<T> is generic, we have to build UI for editing each kind of <T> - hence the need for a protocol to restrict what cavare tweaked.
/// Of course, we can add new TweakViewDataTypes over time, too!
public enum TweakViewDataType {
	case boolean
	case integer
	case int8
	case int16
	case int32
	case int64
	case uInt8
	case uInt16
	case uInt32
	case uInt64
	case cgFloat
	case double
	case uiColor
	case string
	case stringList
	case action
	case date

	public static let allTypes: [TweakViewDataType] = [
		.boolean, .integer,
		.int8, .int16, .int32, .int64,
		.uInt8, .uInt16, .uInt32, .uInt64,
		.cgFloat, .action, .double, .uiColor, .string, .stringList, .date
	]
}

/// An enum for use inside Tweaks' editing UI.
/// Our public type-erasure (AnyTweak) means that this has to be public, unfortunately
/// ...but there's no need for you to directly use this enum.
public enum TweakDefaultData {
	case boolean(defaultValue: Bool)
	case integer(defaultValue: Int, min: Int?, max: Int?, stepSize: Int?)
	case int8(defaultValue: Int8, min: Int8?, max: Int8?, stepSize: Int8?)
	case int16(defaultValue: Int16, min: Int16?, max: Int16?, stepSize: Int16?)
	case int32(defaultValue: Int32, min: Int32?, max: Int32?, stepSize: Int32?)
	case int64(defaultValue: Int64, min: Int64?, max: Int64?, stepSize: Int64?)
	case uInt8(defaultValue: UInt8, min: UInt8?, max: UInt8?, stepSize: UInt8?)
	case uInt16(defaultValue: UInt16, min: UInt16?, max: UInt16?, stepSize: UInt16?)
	case uInt32(defaultValue: UInt32, min: UInt32?, max: UInt32?, stepSize: UInt32?)
	case uInt64(defaultValue: UInt64, min: UInt64?, max: UInt64?, stepSize: UInt64?)
	case float(defaultValue: CGFloat, min: CGFloat?, max: CGFloat?, stepSize: CGFloat?)
	case doubleTweak(defaultValue: Double, min: Double?, max: Double?, stepSize: Double?)
	case color(defaultValue: UIColor)
	case string(defaultValue: String)
	case stringList(defaultValue: StringOption, options: [StringOption])
	case action(defaultValue: TweakAction)
	case date(defaultValue: Date)
}

// MARK: Types that conform to TweakableType

public struct StringOption {
	public let value: String
	init(value: String) {
		self.value = value
	}
}

extension StringOption: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .stringList
	}
}

extension StringOption: Equatable {
	public static func ==(lhs: StringOption, rhs: StringOption) -> Bool {
		return lhs.value == rhs.value
	}

}

extension Bool: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .boolean
	}
}

extension Int: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .integer
	}
}

extension Int8: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .int8
	}
}

extension Int16: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .int16
	}
}

extension Int32: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .int32
	}
}

extension Int64: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .int64
	}
}

extension UInt8: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .uInt8
	}
}

extension UInt16: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .uInt16
	}
}

extension UInt32: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .uInt32
	}
}

extension UInt64: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .uInt64
	}
}

extension CGFloat: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .cgFloat
	}
}

extension Double: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .double
	}
}

extension UIColor: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .uiColor
	}
}

extension String: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .string
	}
}

extension Date: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .date
	}
}
