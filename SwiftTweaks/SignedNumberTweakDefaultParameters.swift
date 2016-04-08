//
//  SignedNumberTweakDefaultParameters.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/8/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

/// A struct you can use to represent default / min / max / stepSize values.
/// (You'll probably only want to use this in creating custom TweakGroupTemplateTypes)
public struct SignedNumberTweakDefaultParameters<T: SignedNumberType> {
	public let defaultValue: T
	public let minValue: T?
	public let maxValue: T?
	public let stepSize: T?
}

public extension Tweak where T: SignedNumberType {
	init(collectionName: String, groupName: String, tweakName: String, defaultParameters: SignedNumberTweakDefaultParameters<T>, customDefaultValue: T?) {
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