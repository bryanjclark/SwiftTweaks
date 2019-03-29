//
//  UIView+BasicAnimationTweakTemplate.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/8/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {

	/// A convenience wrapper for iOS-style spring animations.
	/// Under the hood, it gets the current value for each tweak in the group, and uses that in an animation.
	static func animate(
		basicTweakTemplate: BasicAnimationTweakTemplate,
		tweakStore: TweakStore,
		options: UIView.AnimationOptions,
		animations: @escaping () -> Void,
		completion: ((Bool) -> Void)?
		) {
		UIView.animate(
			withDuration: tweakStore.assign(basicTweakTemplate.duration),
			delay: tweakStore.assign(basicTweakTemplate.delay),
			options: options,
			animations: animations,
			completion: completion
		)
	}
}
