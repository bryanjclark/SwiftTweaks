//
//  TweakStore.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/5/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

/// Looks up the persisted state for tweaks.
public class TweakStore {

	private let tweaks: [AnyTweak]

	public init(tweaks: [AnyTweak]) {
		self.tweaks = tweaks
		// STOPSHIP (bryan): read from persistence model to populate tweakCategories
	}

	public func assign<T>(tweak: Tweak<T>) -> T {
		return self.currentValueForTweak(tweak)
	}


	// MARK: - Internal

	/// Resets all tweaks to their `defaultValue`
	internal func reset() {
		// STOPSHIP (bryan): Implement
	}

	internal func currentValueForTweak<T>(tweak: Tweak<T>) -> T {
		// STOPSHIP (bryan): Return defaultValue in production, else return persistence.currentValue ?? defaultValue
		return tweak.defaultValue
	}
}

/// Identifies tweaks in TweakPersistency
internal protocol TweakIdentifier {
	var persistenceIdentifier: AnyObject { get }
}

/// Persists state for tweaks
internal class TweakPersistency {
	func currentValueForTweakID(tweakID: TweakIdentifier) -> AnyObject? {
		// STOPSHIP (bryan) implement.
		return nil
	}

	func setValue(value: AnyObject?,  forTweakID tweakID: TweakIdentifier) {
		// STOPSHIP (bryan) implement.
	}
}