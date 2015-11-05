//
//  Tweak.swift
//  KATweak
//
//  Created by Bryan Clark on 11/4/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

/// Extend various Foundation elements with Tweakable - there aren't any requirements yet, but this helps restrict what can be extended.
public protocol Tweakable { }
extension CGFloat: Tweakable { }
extension Float: Tweakable { }
extension Double: Tweakable { }

/// Tweaks let you adjust things on the fly
public struct Tweak<T: Tweakable> {
	public let categoryName: String
	public let groupName: String
	public let name: String
	public let defaultValue: T
	public let minimumValue: T?
	public let maximumValue: T?
	public let stepValue: T?

	public var currentValue: T {
		return defaultValue // STOPSHIP (bryan): This is like, the whole point.
	}

	public init(_ categoryName: String, _ groupName: String, _ name: String, _ defaultValue: T, min minimumValue: T? = nil, max maximumValue: T? = nil, stepValue: T? = nil) {

		// STOPSHIP (bryan): Assert that min < default < max. It's going to require that T conform to `Comparable`

		self.categoryName = categoryName
		self.groupName = groupName
		self.name = name
		self.defaultValue = defaultValue
		self.minimumValue = minimumValue
		self.maximumValue = maximumValue
		self.stepValue = stepValue
	}
}

extension Tweak: Hashable {
	public var hashValue: Int {
		return categoryName ^^^ groupName ^^^ name
	}
}

// TODO (bryan): Do we have a way to assert that T and U are the same type?
public func ==<T>(lhs: Tweak<T>, rhs: Tweak<T>) -> Bool {
	return lhs.categoryName == rhs.categoryName && lhs.groupName == rhs.groupName && lhs.name == rhs.name
}