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

	private var tweakCollections: [String: TweakCollection] = [:]

	public init(tweaks: [AnyTweak]) {
		tweaks.forEach { tweak in
			// Find or create its TweakCollection
			var tweakCollection: TweakCollection
			if let existingCollection = tweakCollections[tweak.collectionName] {
				tweakCollection = existingCollection
			} else {
				tweakCollection = TweakCollection(title: tweak.collectionName)
				tweakCollections[tweakCollection.title] = tweakCollection
			}

			// Find or create its TweakGroup
			var tweakGroup: TweakGroup
			if let existingGroup = tweakCollection.tweakGroups[tweak.groupName] {
				tweakGroup = existingGroup
			} else {
				tweakGroup = TweakGroup(title: tweak.groupName)
			}

			// Add the tweak to the tree
			tweakGroup.tweaks[tweak.tweakName] = tweak
			tweakCollection.tweakGroups[tweakGroup.title] = tweakGroup
			tweakCollections[tweakCollection.title] = tweakCollection
		}

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

extension TweakStore {
	internal var sortedTweakCollections: [TweakCollection] {
		return tweakCollections
			.sort { $0.0 < $1.0 }
			.map { return $0.1 }
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