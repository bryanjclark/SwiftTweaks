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
	var tweakViewData: TweakViewData { get }
}

public enum TweakViewData {
	case Switch(value: Bool)
	case Stepper(value: Double)
	case Color(value: UIColor)
}

// The following types are supported as Tweaks.
extension Bool: TweakableType {
	public var tweakViewData: TweakViewData {
		return .Switch(value: self)
	}
}

extension CGFloat: TweakableType {
	public var tweakViewData: TweakViewData {
		return .Stepper(value: Double(self))
	}
}

extension Int: TweakableType {
	public var tweakViewData: TweakViewData {
		return .Stepper(value: Double(self))
	}
}

extension UIColor: TweakableType {
	public var tweakViewData: TweakViewData {
		return .Color(value: self)
	}
}

