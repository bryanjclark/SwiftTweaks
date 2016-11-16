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
/// If T: SignedNumberType, you can declare a min / max / stepSize for a Tweak.
public struct Tweak<T: TweakableType> {
	public let collectionName: String
	public let groupName: String
	public let tweakName: String
	internal let defaultValue: T
	internal let minimumValue: T?	// Only supported for T: SignedNumberType
	internal let maximumValue: T?	// Only supported for T: SignedNumberType
	internal let stepSize: T?		// Only supported for T: SignedNumberType
	internal let options: [T]?		// Only supported for T: StringOption

	internal init(collectionName: String, groupName: String, tweakName: String, defaultValue: T, minimumValue: T? = nil, maximumValue: T? = nil, stepSize: T? = nil, options: [T]? = nil) {

		[collectionName, groupName, tweakName].forEach {
			if $0.containsString(TweakIdentifierSeparator) {
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

}

extension Tweak where T: SignedNumberType {
	/// Creates a Tweak<T> where T: SignedNumberType
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

extension Tweak {
	/// This can't be an initializer because generic types apparently can't handle fixed-type initializers.
	/// If no default value is provided, the first item in the `options` list is used.
	public static func stringList(collectionName: String, _ groupName: String, _ tweakName: String, options: [String], defaultValue: String?=nil) -> Tweak<StringOption> {
		precondition(!options.isEmpty, "Options list cannot be empty (stringList tweak \"\(tweakName)\")")
		precondition(defaultValue == nil || options.indexOf(defaultValue!) != nil,
		             "The default value of the stringList tweak \"\(tweakName)\" must be in the list of options")

		return Tweak<StringOption>(
			collectionName: collectionName,
			groupName: groupName,
			tweakName: tweakName,
			defaultValue: StringOption(value: defaultValue ?? options.first!),
			options: options.map(StringOption.init)
		)
	}
}

extension Tweak: TweakType {
	public var tweak: TweakType {
		return self
	}

	public var tweakDefaultData: TweakDefaultData {
		switch T.tweakViewDataType {
		case .Boolean:
			return .Boolean(defaultValue: (defaultValue as! Bool))
		case .Integer:
			return .Integer(
				defaultValue: defaultValue as! Int,
				min: minimumValue as? Int,
				max: maximumValue as? Int,
				stepSize: stepSize as? Int
			)
		case .CGFloat:
			return .Float(
				defaultValue: defaultValue as! CGFloat,
				min: minimumValue as? CGFloat,
				max: maximumValue as? CGFloat,
				stepSize: stepSize as? CGFloat
			)
		case .Double:
			return .DoubleTweak(
				defaultValue: defaultValue as! Double,
				min: minimumValue as? Double,
				max: maximumValue as? Double,
				stepSize: stepSize as? Double
			)
		case .UIColor:
			return .Color(defaultValue: defaultValue as! UIColor)
		case .StringList:
			return .StringList(
				defaultValue: defaultValue as! StringOption,
				options: options!.map { $0 as! StringOption }
			)
		}
	}

	public var tweakViewDataType: TweakViewDataType {
		return T.tweakViewDataType
	}
}

extension Tweak: Hashable {
	public var hashValue: Int {
		return tweakIdentifier.hashValue
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
