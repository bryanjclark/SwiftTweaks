//
//  ComparableTweakDefaultParameters.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/8/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

/// A struct you can use to represent default / min / max / stepSize values.
/// (You'll probably only want to use this in creating custom TweakGroupTemplateTypes)
public struct ComparableTweakDefaultParameters<T: Comparable> {
	public let defaultValue: T
	public let minValue: T?
	public let maxValue: T?
	public let stepSize: T?

	public init(defaultValue: T, minValue: T? = nil, maxValue: T? = nil, stepSize: T? = nil) {
		self.defaultValue = defaultValue
		self.minValue = minValue
		self.maxValue = maxValue
		self.stepSize = stepSize
	}
}

public extension Tweak where T: Comparable {
	init(collectionName: String, groupName: String, tweakName: String, defaultParameters: ComparableTweakDefaultParameters<T>, customDefaultValue: T?) {
		self.init(
			collectionName: collectionName,
			groupName: groupName,
			tweakName: tweakName,
			defaultValue: customDefaultValue ?? defaultParameters.defaultValue,
			minimumValue: defaultParameters.minValue,
			maximumValue: defaultParameters.maxValue,
			stepSize: defaultParameters.stepSize
		)
	}
}
