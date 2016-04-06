//
//  AppTheme.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/6/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

internal struct AppTheme {
	struct Colors {
		private struct Palette {
			static let blackColor = UIColor.blackColor()
			static let grayColor = UIColor(hex: 0x8E8E93)
			static let tintColor = UIColor(hex: 0x007AFF)
			static let tintColorPressed = UIColor(hex: 0x084BC1)
		}

		static let sectionHeaderTitleColor = Palette.grayColor
		static let controlTinted = Palette.tintColor
		static let controlTintedPressed = Palette.tintColorPressed
	}

	struct Fonts {
		static let sectionHeaderTitleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
	}
}