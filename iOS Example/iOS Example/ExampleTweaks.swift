//
//  ExampleTweaks.swift
//  iOS Example
//
//  Created by Bryan Clark on 11/9/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation
import SwiftTweaks

public struct ExampleTweaks: TweakLibraryType {
	public static let colorBackground = Tweak("General", "Colors", "Background", UIColor(white: 0.95, alpha: 1.0))
	public static let colorTint = Tweak("General", "Colors", "Tint", UIColor.blueColor())
	public static let colorButtonText = Tweak("General", "Colors", "Button Text", UIColor.whiteColor())

	public static let horizontalMargins = Tweak("General", "Layout", "H. Margins", CGFloat(15))
	public static let verticalMargins = Tweak("General", "Layout", "V. Margins", CGFloat(10))

	public static let colorText1 = Tweak("Text", "Color", "text-1", UIColor(white: 0.05, alpha: 1.0))
	public static let colorText2 = Tweak("Text", "Color", "text-2", UIColor(white: 0.15, alpha: 1.0))

	public static let fontSizeText1 = Tweak("Text", "Font Sizes", "title", CGFloat(30))
	public static let fontSizeText2 = Tweak("Text", "Font Sizes", "body", CGFloat(15))

	// Above, we used CGFloat(30) to tell the compiler that the tweak is for a CGFloat, and not an Int.
	// You can also use Tweak<CGFloat> to accomplish this, like so:
	public static let animationDuration = Tweak<CGFloat>("Animation", "Spring Animation", "Duration", 0.5, min: 0.0, max:1.0)
	public static let animationDelay = Tweak<CGFloat>("Animation", "Spring Animation", "Delay", 0.0, min: 0.0, max: 1.0)
	public static let animationDamping = Tweak<CGFloat>("Animation", "Spring Animation", "Damping", 0.7, min: 0.0, max: 1.0)
	public static let animationVelocity = Tweak<CGFloat>("Animation", "Spring Animation", "Velocity", 0.0)

	public static let featureFlagMainScreenHelperText = Tweak("Feature Flags", "Main Screen", "Show Body Text", true)

	public static let defaultStore: TweakStore = {
		let allTweaks: [TweakType] = [
			colorBackground,
			colorTint,
			horizontalMargins,
			verticalMargins,

			colorText1,
			colorText2,

			fontSizeText1,
			fontSizeText2,

			animationDuration,
			animationDelay,
			animationDamping,
			animationVelocity,

			featureFlagMainScreenHelperText
		]

		// NOTE: You can omit the `storeName` parameter if you only have one TweakLibraryType in your application.
		return TweakStore(tweaks: allTweaks.map(AnyTweak.init), storeName: "ExampleTweaks")
	}()
}