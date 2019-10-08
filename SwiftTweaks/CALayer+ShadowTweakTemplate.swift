//
//  CALayer+ShadowTweakTemplate.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 5/19/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import UIKit

public extension CALayer {
	/// A shortcut for applying a ShadowTweakTemplate to a CALayer.
	func apply(shadowTweakTemplate tweakTemplate: ShadowTweakTemplate, fromTweakStore tweakStore: TweakStore) {
		self.shadowColor = tweakStore.assign(tweakTemplate.color).cgColor
		self.shadowOpacity = Float(tweakStore.assign(tweakTemplate.opacity))
		self.shadowOffset = CGSize(width: 0, height: tweakStore.assign(tweakTemplate.offsetY))
		self.shadowRadius = tweakStore.assign(tweakTemplate.radius)
	}
}
