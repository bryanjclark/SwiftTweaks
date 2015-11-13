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
//	var tweakViewData: TweakViewData { get }
	static var tweakViewDataType: TweakViewDataType { get }
}

/// View data used to populate our UI
public enum TweakViewData {
	case Switch(defaultValue: Bool)
	case Stepper(defaultValue: Double, min: Double, max: Double, stepSize: Double)
	case Color(defaultValue: UIColor)
}

/// The data types that are currently supported for SwiftTweaks
public enum TweakViewDataType {
	case Boolean
	case Int
	case CGFloat
	case UIColor
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
		return .Int
	}
}

extension UIColor: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .UIColor
	}
}

