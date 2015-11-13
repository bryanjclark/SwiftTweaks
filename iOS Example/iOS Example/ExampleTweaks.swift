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
	public static let horizontalMargins = Tweak("General", "Layout", "H. Margins", CGFloat(15))

	public static let colorText1 = Tweak("Text", "Color", "text-1", UIColor(white: 0.05, alpha: 1.0))
	public static let colorText2 = Tweak("Text", "Color", "text-2", UIColor(white: 0.15, alpha: 1.0))

	public static let fontSizeText1 = Tweak("Text", "Font Sizes", "title", CGFloat(30))
	public static let fontSizeText2 = Tweak("Text", "Font Sizes", "body", CGFloat(15))

	public static let titleScreenGapBetweenTitleAndBody = Tweak("Main Screen", "Layout", "Title-Body Gap", CGFloat(10))

	public static let titleScreenShowHelperText = Tweak("Main Screen", "Feature Flags", "Show Body Text", true)

	public static let defaultStore: TweakStore = {
		let allTweaks: [TweakType] = [
			colorBackground,
			horizontalMargins,

			colorText1,
			colorText2,

			fontSizeText1,
			fontSizeText2,

			titleScreenGapBetweenTitleAndBody,
			titleScreenShowHelperText
		]
		return TweakStore(tweaks: allTweaks.map(AnyTweak.init))
	}()
}