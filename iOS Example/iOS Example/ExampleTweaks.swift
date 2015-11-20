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

	public static let horizontalMargins = Tweak<CGFloat>("General", "Layout", "H. Margins", defaultValue: 15, min: 0)
	public static let verticalMargins = Tweak<CGFloat>("General", "Layout", "V. Margins", defaultValue: 10, min: 0)

	public static let colorText1 = Tweak("Text", "Color", "text-1", UIColor(white: 0.05, alpha: 1.0))
	public static let colorText2 = Tweak("Text", "Color", "text-2", UIColor(white: 0.15, alpha: 1.0))

	public static let fontSizeText1 = Tweak("Text", "Font Sizes", "title", CGFloat(30))
	public static let fontSizeText2 = Tweak("Text", "Font Sizes", "body", CGFloat(15))

	// Above, we used CGFloat(30) to tell the compiler that the tweak is for a CGFloat, and not an Int.
	// You can also use Tweak<CGFloat> to accomplish this, like so:
	public static let animationDuration = Tweak<Double>("Animation", "Spring Animation", "Duration", defaultValue: 0.5, min: 0.0)
	public static let animationDelay = Tweak<Double>("Animation", "Spring Animation", "Delay", defaultValue: 0.0, min: 0.0, max: 1.0)
	public static let animationDamping = Tweak<CGFloat>("Animation", "Spring Animation", "Damping", defaultValue: 0.7, min: 0.0, max: 1.0)
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

		// Since SwiftTweaks is a dynamic library, you'll need to determine whether tweaks are enabled, and whether the app is running in the simulator.
		// This is fairly straightforward to do - you'll need to add "-D DEBUG" and "-D TARGET_OS_SIMULATOR"
		#if DEBUG
			let tweaksEnabled: Bool = true
		#else
			let tweaksEnabled: Bool = false
		#endif

		#if TARGET_OS_SIMULATOR
			let runningInSimulator = true
		#else
			let runningInSimulator = false
		#endif

		return TweakStore(
			tweaks: allTweaks.map(AnyTweak.init),
			storeName: "ExampleTweaks", 	// NOTE: You can omit the `storeName` parameter if you only have one TweakLibraryType in your application.
			enabled: tweaksEnabled,
			runningInSimulator: runningInSimulator
		)
	}()
}