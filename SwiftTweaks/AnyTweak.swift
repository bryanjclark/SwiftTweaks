//
//  AnyTweak.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/18/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

/// A type-erasure around Tweak<T>, so we can collect them together in TweakLibraryType.
public struct AnyTweak: TweakType {
	public let tweak: TweakType

	public var collectionName: String { return tweak.collectionName }
	public var groupName: String { return tweak.groupName }
	public var tweakName: String { return tweak.tweakName }

	public var tweakViewDataType: TweakViewDataType { return tweak.tweakViewDataType }
	public var tweakDefaultData: TweakDefaultData { return tweak.tweakDefaultData }

	public init(tweak: TweakType) {
		self.tweak = tweak.tweak
	}
}

/// When combined with AnyTweak, this provides our type-erasure around Tweak<T>
public protocol TweakType: TweakClusterType {
	var tweak: TweakType { get }

	var collectionName: String { get }
	var groupName: String { get }
	var tweakName: String { get }

	var tweakViewDataType: TweakViewDataType { get }
	var tweakDefaultData: TweakDefaultData { get }
}

extension TweakType {
	var tweakIdentifier: String {
		return "\(collectionName)\(TweakIdentifierSeparator)\(groupName)\(TweakIdentifierSeparator)\(tweakName)"
	}
}

extension AnyTweak: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(tweakIdentifier)
	}
}

public func ==(lhs: AnyTweak, rhs: AnyTweak) -> Bool {
	return lhs.tweakIdentifier == rhs.tweakIdentifier
}


/// Extend AnyTweak to support identification in disk persistence
extension AnyTweak: TweakIdentifiable {
	var persistenceIdentifier: String { return tweakIdentifier }
}

/// Extend AnyTweak to support easy initialization of a TweakStore
extension AnyTweak: TweakClusterType {
	public var tweakCluster: [AnyTweak] { return [self] }
}
