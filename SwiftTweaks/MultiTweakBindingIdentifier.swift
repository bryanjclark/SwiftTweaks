//
//  MultiTweakBindingIdentifier.swift
//  SwiftTweaks
//
//  Created by Mathijs Kadijk on 31-10-16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

/// Opaque reference to a closure bound to multiple Tweaks
public struct MultiTweakBindingIdentifier: Hashable {
	internal let tweakSet: Set<AnyTweak>
	internal let identifier: UUID

	internal init(tweakSet: Set<AnyTweak>) {
		self.tweakSet = tweakSet
		self.identifier = UUID()
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(tweakSet)
		hasher.combine(TweakIdentifierSeparator)
		hasher.combine(identifier)
	}
}

public func ==(lhs: MultiTweakBindingIdentifier, rhs: MultiTweakBindingIdentifier) -> Bool {
	return lhs.tweakSet == rhs.tweakSet && lhs.identifier == rhs.identifier
}
