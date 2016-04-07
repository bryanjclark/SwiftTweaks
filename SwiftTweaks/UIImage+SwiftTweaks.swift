//
//  UIImage+SwiftTweaks.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/6/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

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

	/// NOTE (bryan): if we just used UIImage(named:_), we get crashes when running in other apps! This takes care of the issue.
	private convenience init?(inThisBundleNamed imageName: String) {
		self.init(named: imageName, inBundle: NSBundle(forClass: TweakTableCell.self), compatibleWithTraitCollection: nil) // NOTE (bryan): Could've used any class in SwiftTweaks here.
	}

	/**
	Returns the image, tinted with the color and blend mode. Useful for press states where a "multiply" blend mode is called for!
	*/
	internal func imageWithColorOverlay(color: UIColor, blendMode: CGBlendMode = .Normal) -> UIImage {
		let rect = CGRect(origin: CGPointZero, size: size)

		UIGraphicsBeginImageContextWithOptions(size, true, 0)
		let context = UIGraphicsGetCurrentContext()

		drawInRect(rect)

		CGContextSetBlendMode(context, blendMode)
		CGContextSetFillColorWithColor(context, color.CGColor)
		CGContextFillRect(context, rect)

		let outputImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return outputImage
	}

	/**
	Returns the image, tinted to the given color.
	*/
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

	/**
	Returns a single-point image, useful for setting the background color of UIButtons for different press states.
	*/
	internal static func imageWithColor(color: UIColor) -> UIImage {
		let rect = CGRect(origin: CGPointZero, size: CGSize(width: 1, height: 1))

		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()

		CGContextSetFillColorWithColor(context, color.CGColor)
		CGContextFillRect(context, rect)

		let outputImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return outputImage
	}

}