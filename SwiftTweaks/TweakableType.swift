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

/// Declares what types are supported as Tweaks.
/// For a type to be supported, it must specify whether it
public protocol TweakableType {
	static var tweakViewDataType: TweakViewDataType { get }
}

/// The data types that are currently supported for SwiftTweaks
public enum TweakViewDataType {
	case Boolean
	case Integer
	case CGFloat
	case UIColor
}


public enum TweakDefaultData {
	case Boolean(defaultValue: Bool)
	case Integer(defaultValue: Int, min: Int?, max: Int?, stepSize: Int?)
	case Float(defaultValue: CGFloat, min: CGFloat?, max: CGFloat?, stepSize: CGFloat?)
	case Color(defaultValue: UIColor)
}

/// View data used to populate our table cells
internal enum TweakViewData {
	case Boolean(value: Bool, defaultValue: Bool)
	case Integer(value: Int, defaultValue: Int, min: Int?, max: Int?, stepSize: Int?)
	case Float(value: CGFloat, defaultValue: CGFloat, min: CGFloat?, max: CGFloat?, stepSize: CGFloat?)
	case Color(value: UIColor, defaultValue: UIColor)
}

// The following types are supported as Tweaks.
extension Bool: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .Boolean
	}
}

extension CGFloat: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .CGFloat
	}
}

extension Int: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .Integer
	}
}

extension UIColor: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .UIColor
	}
}

