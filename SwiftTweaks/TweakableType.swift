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
	static var tweakViewType: TweakViewType { get }
}

public enum TweakViewType {
	case Boolean
	case CGFloat
	case Int
	case Color
}

public enum TweakViewData {
	case Switch
	case Stepper(min: Double?, max: Double?, stepSize: Double?)
	case Color
}

// The following types are supported as Tweaks.
extension Bool: TweakableType {
	public static var tweakViewType: TweakViewType { return .Boolean }
}

extension CGFloat: TweakableType {
	public static var tweakViewType: TweakViewType { return .CGFloat }
}

extension Int: TweakableType {
	public static var tweakViewType: TweakViewType { return .Int }
}

extension UIColor: TweakableType {
	public static var tweakViewType: TweakViewType { return .Color }
}

