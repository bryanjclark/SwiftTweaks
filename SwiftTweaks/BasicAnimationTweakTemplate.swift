//
//  BasicAnimationTweakTemplate.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/8/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

/// A shortcut to create a TweakGroup for a basic animateWithDuration(_:delay:options:animations:completion:)
/// Creates a collection of Tweak<T? with sensible defaults.
/// You can optionally provide a default value for each parameter, but the min / max / stepSize aur automatically created with sensible defaults.
public struct BasicAnimationTweakTemplate: TweakGroupTemplateType {
	public let collectionName: String
	public let groupName: String

	public let duration: Tweak<Double>
	public let delay: Tweak<Double>

	public var tweakCluster: [AnyTweak] {
		return [duration, delay].map(AnyTweak.init)
	}

	public init(
		_ collectionName: String,
		_ groupName: String,
		  duration: Double? = nil,
		  delay: Double? = nil
		) {
		self.collectionName = collectionName
		self.groupName = groupName

		self.duration = Tweak(
			collectionName: collectionName,
			groupName: groupName,
			tweakName: "Duration",
			defaultParameters: BasicAnimationTweakTemplate.durationDefaults,
			customDefaultValue: duration
		)

		self.delay = Tweak(
			collectionName: collectionName,
			groupName: groupName,
			tweakName: "Delay",
			defaultParameters: BasicAnimationTweakTemplate.delayDefaults,
			customDefaultValue: delay
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
}
