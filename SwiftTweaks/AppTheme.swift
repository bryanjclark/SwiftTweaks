//
//  AppTheme.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/6/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import UIKit

/// A central "palette" so to help keep our design consistent.
internal struct AppTheme {
	struct Colors {
		private struct Palette {
			static let whiteColor = UIColor.whiteColor()
			static let blackColor = UIColor.blackColor()
			static let grayColor = UIColor(hex: 0x8E8E93)
			static let pageBackground1 = UIColor(hex: 0xF8F8F8)

			static let tintColor = UIColor(hex: 0x007AFF)
			static let tintColorPressed = UIColor(hex: 0x084BC1)
			static let controlGrayscale = UIColor.darkGrayColor()

			static let secondaryControl = UIColor(hex: 0xC8C7CC)
			static let secondaryControlPressed = UIColor(hex: 0xAFAFB3)

			static let destructiveRed = UIColor(hex: 0xC90911)
		}

		static let sectionHeaderTitleColor = Palette.grayColor

		static let textPrimary = Palette.blackColor

		static let controlTinted = Palette.tintColor
		static let controlTintedPressed = Palette.tintColorPressed
		static let controlDisabled = Palette.secondaryControl
		static let controlDestructive = Palette.destructiveRed
		static let controlSecondary = Palette.secondaryControl
		static let controlSecondaryPressed = Palette.secondaryControlPressed
		static let controlGrayscale = Palette.controlGrayscale

		static let floatingTweakGroupNavBG = Palette.pageBackground1

		static let tableSeparator = Palette.secondaryControl

		static let debugRed = UIColor.redColor().colorWithAlphaComponent(0.3)
		static let debugYellow = UIColor.yellowColor().colorWithAlphaComponent(0.3)
		static let debugBlue = UIColor.blueColor().colorWithAlphaComponent(0.3)

	}

	struct Fonts {
		static let sectionHeaderTitleFont: UIFont = .preferredFontForTextStyle(UIFontTextStyleBody)
	}

	struct Shadows {
		static let floatingShadowColor = Colors.Palette.blackColor.CGColor
		static let floatingShadowOpacity: Float = 0.6
		static let floatingShadowOffset = CGSize(width: 0, height: 1)
		static let floatingShadowRadius: CGFloat = 4

		static let floatingNavShadowColor = floatingShadowColor
		static let floatingNavShadowOpacity: Float = 0.1
		static let floatingNavShadowOffset = floatingShadowOffset
		static let floatingNavShadowRadius: CGFloat = 0
	}
}