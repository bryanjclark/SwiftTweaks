//
//  SpringAnimationTweakTemplate.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/8/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation
import UIKit

/// A shortcut to create a TweakGroup for an iOS-style spring animation.
/// Creates a collection of Tweak<T> with sensible defaults for a spring animation.
/// You can optionally provide a default value for each parameter, but the min / max / stepSize are automatically created with sensible defaults.
public struct SpringAnimationTweakTemplate: TweakGroupTemplateType {
	public let collectionName: String
	public let groupName: String
	
	public let duration: Tweak<Double>
	public let delay: Tweak<Double>
	public let damping: Tweak<CGFloat>
	public let initialSpringVelocity: Tweak<CGFloat>

	public var tweakCluster: [AnyTweak] {
		return [duration, delay, damping, initialSpringVelocity].map(AnyTweak.init)
	}

	public init(
		  _ collectionName: String,
		  _ groupName: String,
		    duration: Double? = nil,
		    delay: Double? = nil,
		    damping: CGFloat? = nil,
		    initialSpringVelocity: CGFloat? = nil
	) {
		self.collectionName = collectionName
		self.groupName = groupName

		self.duration = Tweak(
			collectionName: collectionName,
			groupName: groupName,
			tweakName: "Duration",
			defaultParameters: SpringAnimationTweakTemplate.durationDefaults,
			customDefaultValue: duration
		)

		self.delay = Tweak(
			collectionName: collectionName,
			groupName: groupName,
			tweakName: "Delay",
			defaultParameters: SpringAnimationTweakTemplate.delayDefaults,
			customDefaultValue: delay
		)

		self.damping = Tweak(
			collectionName: collectionName,
			groupName: groupName,
			tweakName: "Damping",
			defaultParameters: SpringAnimationTweakTemplate.dampingDefaults,
			customDefaultValue: damping
		)

		self.initialSpringVelocity = Tweak(
			collectionName: collectionName,
			groupName: groupName,
			tweakName: "Initial V.",
			defaultParameters: SpringAnimationTweakTemplate.initialSpringVelocityDefaults,
			customDefaultValue: initialSpringVelocity
		)
	}

	private static let durationDefaults = ComparableTweakDefaultParameters<Double>(
		defaultValue: 0.3,
		minValue: 0.0,
		maxValue: 2.0,
		stepSize: 0.01
	)

	private static let delayDefaults = ComparableTweakDefaultParameters<Double>(
		defaultValue: 0.0,
		minValue: 0.0,
		maxValue: 5.0,
		stepSize: 0.01
	)

	private static let dampingDefaults = ComparableTweakDefaultParameters<CGFloat>(
		defaultValue: 0.8,
		minValue: 0.0,
		maxValue: 1.0,
		stepSize: 0.01
	)

	private static let initialSpringVelocityDefaults = ComparableTweakDefaultParameters<CGFloat>(
		defaultValue: 0.0,
		minValue: nil,
		maxValue: nil,
		stepSize: 0.01
	)
}
