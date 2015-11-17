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
	private var tweakBindings: [String: [(TweakableType) -> Void]] = [:]

	private let persistence: TweakPersistency

	/// Creates a TweakStore, with information persisted on-disk. 
	/// If you want to have multiple TweakStores in your app, you can pass in a unique storeName to keep it separate from others on disk.
	public init(tweaks: [AnyTweak], storeName: String = "Tweaks") {
		self.persistence = TweakPersistency(identifier: storeName)

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
	}

	/// Returns the current value for a given tweak
	public func assign<T>(tweak: Tweak<T>) -> T {
		return self.currentValueForTweak(tweak)
	}

	/// Immediately binds the currentValue of a given tweak, and then continues to update whenever the tweak changes.
	public func bind<T>(tweak: Tweak<T>, binding: (T) -> Void) {
		// Cache the binding in our dictionary
		let existingTweakBindings = tweakBindings[tweak.persistenceIdentifier] ?? []
		let tweakableTypeBinding = binding as! (TweakableType) -> Void
		tweakBindings[tweak.persistenceIdentifier] = existingTweakBindings + [tweakableTypeBinding]

		// Then return the current value for the tweak
		binding(currentValueForTweak(tweak))
	}

	// MARK: - Internal
	
	/// Resets all tweaks to their `defaultValue`
	internal func reset() {
		persistence.clearAllData()
	}

	internal func currentValueForTweak<T>(tweak: Tweak<T>) -> T {
		// STOPSHIP (bryan): Return defaultValue in production, else return persistence.currentValue ?? defaultValue
		return shouldAllowTweaks ? persistence.currentValueForTweak(tweak) ?? tweak.defaultValue : tweak.defaultValue
	}

	internal func currentViewDataForTweak(tweak: AnyTweak) -> TweakViewData {
		let cachedValue = persistence.currentValueForTweakIdentifiable(tweak)

		switch tweak.tweakDefaultData {
		case let .Boolean(defaultValue: defaultValue):
			let currentValue = cachedValue as? Bool ?? defaultValue
			return .Boolean(value: currentValue, defaultValue: defaultValue)
		case let .Integer(defaultValue: defaultValue, min: min, max: max, stepSize: step):
			let currentValue = cachedValue as? Int ?? defaultValue
			return .Integer(value: currentValue, defaultValue: defaultValue, min: min, max: max, stepSize: step)
		case let .Float(defaultValue: defaultValue, min: min, max: max, stepSize: step):
			let currentValue = cachedValue as? CGFloat ?? defaultValue
			return .Float(value: currentValue, defaultValue: defaultValue, min: min, max: max, stepSize: step)
		case let .Color(defaultValue: defaultValue):
			let currentValue = cachedValue as? UIColor ?? defaultValue
			return .Color(value: currentValue, defaultValue: defaultValue)
		}
	}

	internal func setValue(viewData: TweakViewData, forTweak tweak: AnyTweak) {
		let value: TweakableType
		switch viewData {
		case let .Boolean(value: boolValue, defaultValue: _):
			value = boolValue
		case let .Integer(value: intValue, defaultValue: _, min: _, max: _, stepSize: _):
			value = intValue
		case let .Float(value: floatValue, defaultValue: _, min: _, max: _, stepSize: _):
			value = floatValue
		case let .Color(value: colorValue, defaultValue: _):
			value = colorValue
		}
		persistence.setValue(value, forTweakIdentifiable: tweak)
		tweakBindings[tweak.persistenceIdentifier]?.forEach { $0(value) }
	}

	// MARK - Private

	private var shouldAllowTweaks: Bool {
		return true // STOPSHIP (bryan): figure out whether we're in production or debug.
	}
}

extension TweakStore {
	internal var sortedTweakCollections: [TweakCollection] {
		return tweakCollections
			.sort { $0.0 < $1.0 }
			.map { return $0.1 }
	}
}