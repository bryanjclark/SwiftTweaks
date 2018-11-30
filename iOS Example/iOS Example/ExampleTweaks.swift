//
//  ExampleTweaks.swift
//  iOS Example
//
//  Created by Bryan Clark on 11/9/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit
import SwiftTweaks

public struct ExampleTweaks: TweakLibraryType {
	public static let colorBackground = Tweak("General", "Colors", "Background", UIColor(white: 0.98, alpha: 1.0))
	public static let colorTint = Tweak("General", "Colors", "Tint", UIColor(hue: 5/255, saturation: 0.61, brightness: 0.89, alpha: 1))
	public static let colorButtonText = Tweak("General", "Colors", "Button Text", UIColor.white)

	// Tweaks work *great* with numbers, you just need to tell the compiler
	// what kind of number you're using (Int, CGFloat, or Double)
	public static let fontSizeText1 = Tweak<CGFloat>("Text", "Font Sizes", "title", 32)
	public static let fontSizeText2 = Tweak<CGFloat>("Text", "Font Sizes", "body", 18)

	// If the tweak is for a number, you can optionally add default / min / max / stepSize options to restrict the values.
	// Maybe you've got a number that must be non-negative, for example:
	public static let horizontalMargins = Tweak<CGFloat>("General", "Layout", "H. Margins", defaultValue: 16, min: 0)
	public static let verticalMargins = Tweak<CGFloat>("General", "Layout", "V. Margins", defaultValue: 16, min: 0)

	public static let colorText1 = Tweak("Text", "Color", "text-1", UIColor.black)
	public static let colorText2 = Tweak("Text", "Color", "text-2", UIColor(hue: 213/255, saturation: 0.07, brightness: 0.58, alpha: 1))

    public static let title = Tweak("Text", "Text", "Title", options: ["SwiftTweaks", "Welcome!", "Example"])
	public static let subtitle = Tweak<String>("Text", "Text", "Subtitle", "Subtitle")

	// Tweaks are often used in combination with each other, so we have some templates available for ease-of-use:
	public static let buttonAnimation = SpringAnimationTweakTemplate("Animation", "Button Animation", duration: 0.5) // Note: "duration" is optional, if you don't provide it, there's a sensible default!

    // You can even run your own code from a tweak! More on this in this example's ViewController.swift file
    public static let actionPrintToConsole = Tweak<TweakAction>("General", "Actions", "Print to console")
    
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
			subtitle,

			fontSizeText1,
			fontSizeText2,

			buttonAnimation,

            actionPrintToConsole,
            
			featureFlagMainScreenHelperText
		]

		// Since SwiftTweaks is a dynamic library, you'll need to determine whether tweaks are enabled.
		// Try using the DEBUG flag (add "-D DEBUG" to "Other Swift Flags" in your project's Build Settings).
		// Below, we'll use TweakDebug.isActive, which is a shortcut to check the DEBUG flag.

		return TweakStore(
			tweaks: allTweaks,
			storeName: "ExampleTweaks", 	// NOTE: You can omit the `storeName` parameter if you only have one TweakLibraryType in your application.
			enabled: TweakDebug.isActive
		)
	}()
}
