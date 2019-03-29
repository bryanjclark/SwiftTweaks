//
//  Tweak.swift
//  KATweak
//
//  Created by Bryan Clark on 11/4/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

/// Tweaks let you adjust things on the fly.
/// Because each T needs a UI component, we have to restrict what T can be - hence T: TweakableType.
/// If T: Comparable, you can declare a min / max / stepSize for a Tweak.
public struct Tweak<T: TweakableType> {
	public let collectionName: String
	public let groupName: String
	public let tweakName: String
	internal let defaultValue: T
	internal let minimumValue: T?	// Only supported for T: Comparable
	internal let maximumValue: T?	// Only supported for T: Comparable
	internal let stepSize: T?		// Only supported for T: Comparable
	internal let options: [T]?		// Only supported for T: StringOption

	internal init(collectionName: String, groupName: String, tweakName: String, defaultValue: T, minimumValue: T? = nil, maximumValue: T? = nil, stepSize: T? = nil, options: [T]? = nil) {

		[collectionName, groupName, tweakName].forEach {
			if $0.contains(TweakIdentifierSeparator) {
				assertionFailure("The substring `\(TweakIdentifierSeparator)` can't be used in a tweak name, group name, or collection name.")
			}
		}

		self.collectionName = collectionName
		self.groupName = groupName
		self.tweakName = tweakName
		self.defaultValue = defaultValue
		self.minimumValue = minimumValue
		self.maximumValue = maximumValue
		self.stepSize = stepSize
		self.options = options
	}
}

internal let TweakIdentifierSeparator = "|"

extension Tweak {
	public init(_ collectionName: String, _ groupName: String, _ tweakName: String, _ defaultValue: T) {
		self.init(
			collectionName: collectionName,
			groupName: groupName,
			tweakName: tweakName,
			defaultValue: defaultValue
		)
	}
	
	public init(_ collectionName: String, _ groupName: String, _ tweakName: String, _ defaultValueProvider: () -> T) {
		self.init(
			collectionName: collectionName,
			groupName: groupName,
			tweakName: tweakName,
			defaultValue: defaultValueProvider()
		)
	}

}

extension Tweak where T: Comparable {
	/// Creates a Tweak<T> where T: Comparable
	/// You can optionally provide a min / max / stepSize to restrict the bounds and behavior of a tweak.
	/// The step size is "how much does the value change when I tap the UIStepper"
	public init(_ collectionName: String, _ groupName: String, _ tweakName: String, defaultValue: T, min minimumValue: T? = nil, max maximumValue: T? = nil, stepSize: T? = nil) {

		// Assert that the tweak's defaultValue is between its min and max (if they exist)
		if clip(defaultValue, minimumValue, maximumValue) != defaultValue {
			assertionFailure("A tweak's default value must be between its min and max. Your tweak \"\(tweakName)\" doesn't meet this requirement.")
		}

		self.init(
			collectionName: collectionName,
			groupName: groupName,
			tweakName: tweakName,
			defaultValue: defaultValue,
			minimumValue: minimumValue,
			maximumValue: maximumValue,
			stepSize: stepSize
		)
	}
}

extension Tweak where T == StringOption {
	public init(_ collectionName: String, _ groupName: String, _ tweakName: String, options: [String], defaultValue: String? = nil) {
		precondition(!options.isEmpty, "Options list cannot be empty (stringList tweak \"\(tweakName)\")")
		precondition(
			defaultValue == nil || options.contains(defaultValue!),
			"The default value \"\(String(describing: defaultValue))\" of the stringList tweak \"\(tweakName)\" must be in the list of options \"\(options)\""
		)

		self.init(
			collectionName: collectionName,
			groupName: groupName,
			tweakName: tweakName,
			defaultValue: StringOption(value: defaultValue ?? options[0]),
			options: options.map(StringOption.init)
		)
	}
}

extension Tweak {
	@available(*, deprecated, message: "replaced by 'init(_:_:_options:defaultValue:)'", renamed: "init(_:_:_options:defaultValue:)")
	public static func stringList(_ collectionName: String, _ groupName: String, _ tweakName: String, options: [String], defaultValue: String? = nil) -> Tweak<StringOption> {

		return Tweak<StringOption>(
		collectionName,
		groupName,
		tweakName,
		options: options,
		defaultValue: defaultValue
		)
	}
}

extension Tweak: TweakType {
	public var tweak: TweakType {
		return self
	}

	public var tweakDefaultData: TweakDefaultData {
		switch T.tweakViewDataType {
		case .boolean:
			return .boolean(defaultValue: (defaultValue as! Bool))
		case .integer:
			return .integer(
				defaultValue: defaultValue as! Int,
				min: minimumValue as? Int,
				max: maximumValue as? Int,
				stepSize: stepSize as? Int
			)
		case .cgFloat:
			return .float(
				defaultValue: defaultValue as! CGFloat,
				min: minimumValue as? CGFloat,
				max: maximumValue as? CGFloat,
				stepSize: stepSize as? CGFloat
			)
		case .double:
			return .doubleTweak(
				defaultValue: defaultValue as! Double,
				min: minimumValue as? Double,
				max: maximumValue as? Double,
				stepSize: stepSize as? Double
			)
		case .uiColor:
			return .color(defaultValue: defaultValue as! UIColor)
		case .string:
			return .string(defaultValue: defaultValue as! String)
		case .stringList:
			return .stringList(
				defaultValue: defaultValue as! StringOption,
				options: options!.map { $0 as! StringOption }
			)
		case .action:
			return .action(
				defaultValue: defaultValue as! TweakAction
			)
		}
	}

	public var tweakViewDataType: TweakViewDataType {
		return T.tweakViewDataType
	}
}

extension Tweak: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(tweakIdentifier)
	}
}

public func ==<T>(lhs: Tweak<T>, rhs: Tweak<T>) -> Bool {
	return lhs.tweakIdentifier == rhs.tweakIdentifier
}

/// Extend Tweak to support identification in bindings
extension Tweak: TweakIdentifiable {
	var persistenceIdentifier: String { return tweakIdentifier }
}

/// Extend Tweak to support easy initialization of a TweakStore
extension Tweak: TweakClusterType {
	public var tweakCluster: [AnyTweak] { return [AnyTweak.init(tweak: self)] }
}
