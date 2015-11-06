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

/// Tweaks let you adjust things on the fly
public struct Tweak<T: TweakableType> {
	public let collectionName: String
	public let groupName: String
	public let tweakName: String
	internal let defaultValue: T
	internal let minimumValue: T?	// Only supported for T: SignedNumberType
	internal let maximumValue: T?	// Only supported for T: SignedNumberType
	internal let stepSize: T?		// Only supported for T: SignedNumberType

	public init(_ collectionName: String, _ groupName: String, _ tweakName: String, _	defaultValue: T, minimumValue: T? = nil, maximumValue: T? = nil, stepSize: T? = nil) {
		self.collectionName = collectionName
		self.groupName = groupName
		self.tweakName = tweakName
		self.defaultValue = defaultValue
		self.minimumValue = minimumValue
		self.maximumValue = maximumValue
		self.stepSize = stepSize
	}
}

extension Tweak: TweakType {
	public var tweak: TweakType {
		return self
	}
}

extension Tweak {
	public func currentValue(store: TweakStore) -> T {
		return store.currentValueForTweak(self) ?? defaultValue
	}
}

extension Tweak: Hashable {
	public var hashValue: Int {
		return collectionName.hashValue ^^^ groupName.hashValue ^^^ tweakName.hashValue
	}
}

public func ==<T>(lhs: Tweak<T>, rhs: Tweak<T>) -> Bool {
	return lhs.collectionName == rhs.collectionName && lhs.groupName == rhs.groupName && lhs.tweakName == rhs.tweakName
}