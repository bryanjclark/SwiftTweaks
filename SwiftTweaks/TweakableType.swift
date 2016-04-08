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
/// While Tweak<T> is generic, we have to build UI for editing each kind of <T> - hence the need for a protocol to restrict what can be tweaked.
/// Of course, we can add new TweakViewDataTypes over time, too!
public enum TweakViewDataType {
	case Boolean
	case Integer
	case CGFloat
	case Double
	case UIColor

	public static let allTypes: [TweakViewDataType] = [
		.Boolean, .Integer, .CGFloat, .Double, .UIColor
	]
}

/// An enum for use inside Tweaks' editing UI.
/// Our public type-erasure (AnyTweak) means that this has to be public, unfortunately
/// ...but there's no need for you to directly use this enum.
public enum TweakDefaultData {
	case Boolean(defaultValue: Bool)
	case Integer(defaultValue: Int, min: Int?, max: Int?, stepSize: Int?)
	case Float(defaultValue: CGFloat, min: CGFloat?, max: CGFloat?, stepSize: CGFloat?)
	case DoubleTweak(defaultValue: Double, min: Double?, max: Double?, stepSize: Double?)
	case Color(defaultValue: UIColor)
}

// MARK: Types that conform to TweakableType

extension Bool: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .Boolean
	}
}

extension Int: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .Integer
	}
}

extension CGFloat: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .CGFloat
	}
}

extension Double: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .Double
	}
}

extension UIColor: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .UIColor
	}
}

