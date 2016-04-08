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
		case DisclosureIndicator = "disclosure-indicator"
		case FloatingPlusButton = "floating-plus-button"
		case FloatingCloseButton = "floating-ui-close"
		case FloatingMinimizedArrow = "floating-ui-minimized-arrow"
	}

	convenience init(swiftTweaksImage: SwiftTweaksImage) {
		self.init(inThisBundleNamed: swiftTweaksImage.rawValue)!
	}

	// NOTE (bryan): if we just used UIImage(named:_), we get crashes when running in other apps!
	// (Why? Because by default, iOS searches in your app's bundle, but we need to redirect that to the bundle associated with SwiftTweaks
	private convenience init?(inThisBundleNamed imageName: String) {
		self.init(named: imageName, inBundle: NSBundle(forClass: TweakTableCell.self), compatibleWithTraitCollection: nil) // NOTE (bryan): Could've used any class in SwiftTweaks here.
	}

	/// Returns the image, tinted to the given color.
	internal func imageTintedWithColor(color: UIColor) -> UIImage {
		let imageRect = CGRect(origin: CGPoint.zero, size: self.size)

		UIGraphicsBeginImageContextWithOptions(imageRect.size, false, 0.0) // Retina aware.

		drawInRect(imageRect)
		color.set()
		UIRectFillUsingBlendMode(imageRect, .SourceIn)

		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image
	}
}