//
//  HitTransparentWindow.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/6/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import UIKit


/// A UIWindow that ignores touch events outside of its bounds, allowing it to float over another interactive UI.
/// Enables SwiftTweaks' floating UI.
/// Inspired by the *super-handy* TunableSpec: https://github.com/kongtomorrow/TunableSpec/blob/master/KFTunableSpec.m
internal final class HitTransparentWindow: UIWindow {
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let result = super.hitTest(point, with: event)
		return (result == self) ? nil : result
	}
}
