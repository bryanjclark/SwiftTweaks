//
//  UIView+TweakGroupTemplateSpringAnimation.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/8/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import UIKit

public extension UIView {

	/// A convenience wrapper for iOS-style spring animations.
	/// Under the hood, it gets the current value for each tweak in the group, and uses that in an animation.
	public static func animateWithTweakGroupSpringAnimation(
		tweakGroupTemplateSpringAnimation: TweakGroupTemplateSpringAnimation,
		tweakStore: TweakStore,
		options: UIViewAnimationOptions,
		animations: () -> Void,
		completion: ((Bool) -> Void)?
	) {
		UIView.animateWithDuration(
			tweakStore.assign(tweakGroupTemplateSpringAnimation.duration),
			delay: tweakStore.assign(tweakGroupTemplateSpringAnimation.delay),
			usingSpringWithDamping: tweakStore.assign(tweakGroupTemplateSpringAnimation.damping),
			initialSpringVelocity: tweakStore.assign(tweakGroupTemplateSpringAnimation.initialSpringVelocity),
			options: options,
			animations:
			animations,
			completion: completion)
	}
}