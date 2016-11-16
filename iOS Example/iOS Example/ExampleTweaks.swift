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

	// Tweaks work *great* with numbers, you just need to tell the compiler
	// what kind of number you're using (Int, CGFloat, or Double)
	public static let fontSizeText1 = Tweak<CGFloat>("Text", "Font Sizes", "title", 30)
	public static let fontSizeText2 = Tweak<CGFloat>("Text", "Font Sizes", "body", 15)

	// If the tweak is for a number, you can optionally add default / min / max / stepSize options to restrict the values.
	// Maybe you've got a number that must be non-negative, for example:
	public static let horizontalMargins = Tweak<CGFloat>("General", "Layout", "H. Margins", defaultValue: 15, min: 0)
	public static let verticalMargins = Tweak<CGFloat>("General", "Layout", "V. Margins", defaultValue: 10, min: 0)

	public static let colorText1 = Tweak("Text", "Color", "text-1", UIColor(white: 0.05, alpha: 1.0))
	public static let colorText2 = Tweak("Text", "Color", "text-2", UIColor(white: 0.15, alpha: 1.0))

    public static let title = Tweak<StringOption>.stringList("Text", "Text", "Title", options: ["SwiftTweaks", "Welcome!", "Example"])

	// Tweaks are often used in combination with each other, so we have some templates available for ease-of-use:
	public static let buttonAnimation = SpringAnimationTweakTemplate("Animation", "Button Animation", duration: 0.5) // Note: "duration" is optional, if you don't provide it, there's a sensible default!

	/*
	Seriously, SpringAnimationTweakTemplate is *THE BEST* - here's what the equivalent would be if you were to make that by hand:

	public static let animationDuration = Tweak<Double>("Animation", "Button Animation", "Duration", defaultValue: 0.5, min: 0.0)
	public static let animationDelay = Tweak<Double>("Animation", "Button Animation", "Delay", defaultValue: 0.0, min: 0.0, max: 1.0)
	public static let animationDamping = Tweak<CGFloat>("Animation", "Button Animation", "Damping", defaultValue: 0.7, min: 0.0, max: 1.0)
	public static let animationVelocity = Tweak<CGFloat>("Animation", "Button Animation", "Initial V.", 0.0)

	*/

	public static let featureFlagMainScreenHelperText = Tweak("Feature Flags", "Main Screen", "Show Body Text", true)

	public static let defaultStore: TweakStore = {
		let allTweaks: [TweakClusterType] = [
			colorBackground,
			colorTint,
			colorButtonText,
			horizontalMargins,
			verticalMargins,

			colorText1,
			colorText2,
			title,

			fontSizeText1,
			fontSizeText2,

			buttonAnimation,

			featureFlagMainScreenHelperText
		]

		// Since SwiftTweaks is a dynamic library, you'll need to determine whether tweaks are enabled.
		// Try using the DEBUG flag (add "-D DEBUG" to "Other Swift Flags" in your project's Build Settings).
		#if DEBUG
			let tweaksEnabled: Bool = true
		#else
			let tweaksEnabled: Bool = false
		#endif

		return TweakStore(
			tweaks: allTweaks,
			storeName: "ExampleTweaks", 	// NOTE: You can omit the `storeName` parameter if you only have one TweakLibraryType in your application.
			enabled: tweaksEnabled
		)
	}()
}