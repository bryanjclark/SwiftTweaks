//
//  UIImage+SwiftTweaks.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/6/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import UIKit

internal extension UIImage {

	enum SwiftTweaksImage: String {
		case disclosureIndicator = "disclosure-indicator"
		case floatingPlusButton = "floating-plus-button"
		case floatingCloseButton = "floating-ui-close"
		case floatingReopenButton = "floating-ui-open-tweaks"
		case floatingMinimizedArrow = "floating-ui-minimized-arrow"
	}

	convenience init(swiftTweaksImage: SwiftTweaksImage) {
		self.init(inThisBundleNamed: swiftTweaksImage.rawValue)!
	}

	// NOTE (bryan): if we just used UIImage(named:_), we get crashes when running in other apps!
	// (Why? Because by default, iOS searches in your app's bundle, but we need to redirect that to the bundle associated with SwiftTweaks
	private convenience init?(inThisBundleNamed imageName: String) {
		#if SWIFT_PACKAGE
		self.init(named: imageName, in: Bundle.module, compatibleWith: nil)
		#else
		self.init(named: imageName, in: Bundle(for: TweakTableCell.self), compatibleWith: nil) // NOTE (bryan): Could've used any class in SwiftTweaks here.
		#endif
	}

	/// Returns the image, tinted to the given color.
	func imageTintedWithColor(_ color: UIColor) -> UIImage {
		let imageRect = CGRect(origin: CGPoint.zero, size: self.size)

		UIGraphicsBeginImageContextWithOptions(imageRect.size, false, 0.0) // Retina aware.

		draw(in: imageRect)
		color.set()
		UIRectFillUsingBlendMode(imageRect, .sourceIn)

		let image = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()

		return image
	}
}
