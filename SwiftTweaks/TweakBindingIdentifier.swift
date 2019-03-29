//
//  TweakBindingIdentifier.swift
//  SwiftTweaks
//
//  Created by Mathijs Kadijk on 31-10-16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

/// Opaque reference to a closure bound to a Tweak
public struct TweakBindingIdentifier: Hashable {
	internal let tweak: AnyTweak
	internal let identifier: UUID

	internal init(tweak: AnyTweak) {
		self.tweak = tweak
		self.identifier = UUID()
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(tweak.tweakIdentifier)
		hasher.combine(TweakIdentifierSeparator)
		hasher.combine(identifier)
	}
}

public func ==(lhs: TweakBindingIdentifier, rhs: TweakBindingIdentifier) -> Bool {
	return lhs.tweak == rhs.tweak && lhs.identifier == rhs.identifier
}
