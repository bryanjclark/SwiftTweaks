//
//  Playground.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/5/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

public struct KHATweaks: TweakLibraryType {
	public static let colorTint = Tweak("Colors", "Global", "tint", UIColor.greenColor())
	public static let colorBackground = Tweak("Colors", "Global", "page-bg-1", UIColor(white: 0.9, alpha: 1.0))

	public static let colorText1 = Tweak("Colors", "Text", "text-1", UIColor.blackColor())
	public static let colorText2 = Tweak("Colors", "Text", "text-2", UIColor.darkGrayColor())
	public static let colorText3 = Tweak("Colors", "Text", "text-3", UIColor.grayColor())

	public static let videoPlayerTabAnimationDuration = Tweak("Video Player", "Tab Animation", "Duration", CGFloat(0.2), minimumValue: 0.1, maximumValue: 2.0, stepSize: 0.01)

	public static let exploreTabFeaturedItemsCount = Tweak("Explore Tab", "Featured Items", "Count", Int(5), minimumValue: 3, maximumValue: 8, stepSize: 1)

	public static let userProfileShowUsername = Tweak("User Profile", "Header", "Show Username", true)
	public static let userProfileAvatarDiameter = Tweak("User Profile", "Header", "Avatar Diameter", CGFloat(96), stepSize: 1)


	// MARK: TweakLibraryType

	public static let defaultStore: TweakStore = {
		// STOPSHIP (bryan): Explore whether we can use Swift's `Mirror` to accomplish this!
		let allTweaks: [TweakType] = [
			colorTint,
			colorText1,
			colorText2,
			colorText3,

			videoPlayerTabAnimationDuration,

			exploreTabFeaturedItemsCount,

			userProfileShowUsername,
			userProfileAvatarDiameter
		]

		return TweakStore(tweaks: allTweaks.map(AnyTweak.init))
	}()
}

public class MyViewController: UIViewController {
	private let backgroundColor: UIColor = KHATweaks.assign(KHATweaks.colorBackground)

	init(foo: String) {
		super.init(nibName: nil, bundle: nil)
	}

	required public init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}