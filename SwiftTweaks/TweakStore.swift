//
//  TweakStore.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/5/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

/// Looks up the persisted state for tweaks.
public final class TweakStore {

	/// The "tree structure" for our Tweaks UI.
	fileprivate var tweakCollections: [String: TweakCollection] = [:]

	/// Useful when exporting or checking that a tweak exists in tweakCollections
	private let allTweaks: Set<AnyTweak>

	/// We hold a reference to the storeName so we can have a better error message if a tweak doesn't exist in allTweaks.
	private let storeName: String

	/// Caches "single" bindings - when a tweak is updated, we'll call each of the corresponding bindings.
	private var tweakBindings: [AnyTweak: [AnyTweakBinding]] = [:]

	/// Caches "multi" bindings - when any tweak in a Set is updated, we'll call each of the corresponding bindings.
	private var tweakSetBindings: [Set<AnyTweak>: [MultiTweakBinding]] = [:]

	/// Persists tweaks' currentValues and maintains them on disk.
	private let persistence: TweakPersistency

	/// Determines whether tweaks are enabled, and whether the tweaks UI is accessible
	internal let enabled: Bool

	/// Creates a TweakStore, with information persisted on-disk. 
	/// If you want to have multiple TweakStores in your app, you can pass in a unique storeName to keep it separate from others on disk.
	public init(tweaks: [TweakClusterType], storeName: String = "Tweaks", enabled: Bool, appGroup: String? = nil) {
		self.persistence = TweakPersistency(identifier: storeName, appGroup: appGroup)
		self.storeName = storeName
		self.enabled = enabled
		self.allTweaks = Set(tweaks.reduce([]) { $0 + $1.tweakCluster })

		self.allTweaks.forEach { tweak in
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
	public func assign<T>(_ tweak: Tweak<T>) -> T {
		return self.currentValueForTweak(tweak)
	}

	public func bind<T>(_ tweak: Tweak<T>, binding: @escaping (T) -> Void) -> TweakBindingIdentifier {
		// Create the TweakBinding<T>, and wrap it in our type-erasing AnyTweakBinding
		let tweakBinding = TweakBinding(tweak: tweak, binding: binding)
		let anyTweakBinding = AnyTweakBinding(tweakBinding: tweakBinding)

		// Cache the binding
		let anyTweak = AnyTweak(tweak: tweak)
		let existingTweakBindings = tweakBindings[anyTweak] ?? []
		tweakBindings[anyTweak] = existingTweakBindings + [anyTweakBinding]

		// Then immediately apply the binding on whatever current value we have
		binding(currentValueForTweak(tweak))

		return tweakBinding.identifier
	}

	public func unbind(_ identifier: TweakBindingIdentifier) {
		let existingTweakBindings = tweakBindings[identifier.tweak] ?? []
		tweakBindings[identifier.tweak] = existingTweakBindings.filter { $0.identifier != identifier }
	}

	public func bindMultiple(_ tweaks: [TweakType], binding: @escaping () -> Void) -> MultiTweakBindingIdentifier {
		// Convert the array (which makes it easier to call a `bindTweakSet`) into a set (which makes it possible to cache the tweakSet)
		let tweakSet = Set(tweaks.map(AnyTweak.init))

		let tweakBinding = MultiTweakBinding(tweakSet: tweakSet, binding: binding)

		// Cache the cluster binding
		let existingTweakSetBindings = tweakSetBindings[tweakSet] ?? []
		tweakSetBindings[tweakSet] = existingTweakSetBindings + [tweakBinding]

		// Immediately call the binding
		binding()

		return tweakBinding.identifier
	}

	public func unbindMultiple(_ identifier: MultiTweakBindingIdentifier) {
		let existingTweakSetBindings = tweakSetBindings[identifier.tweakSet] ?? []
		tweakSetBindings[identifier.tweakSet] = existingTweakSetBindings.filter { $0.identifier != identifier }
	}

	// MARK: - Internal
	
	/// Resets all tweaks to their `defaultValue`
	internal func reset() {
		persistence.clearAllData()

		// Go through all tweaks in our library, and call any bindings they're attached to.
		tweakCollections.values.reduce([]) { $0 + $1.sortedTweakGroups.reduce([]) { $0 + $1.sortedTweaks } }
			.forEach { updateBindingsForTweak($0)
		}

	}

	internal func currentValueForTweak<T>(_ tweak: Tweak<T>) -> T {
		if allTweaks.contains(AnyTweak(tweak: tweak)) {
			return enabled ? persistence.currentValueForTweak(tweak) ?? tweak.defaultValue : tweak.defaultValue
		} else {
			print("Error: the tweak \"\(tweak.tweakIdentifier)\" isn't included in the tweak store \"\(storeName)\". Returning the default value.")
			return tweak.defaultValue
		}
	}

	internal func currentViewDataForTweak(_ tweak: AnyTweak) -> TweakViewData {
		let cachedValue = persistence.persistedValueForTweakIdentifiable(tweak)

		switch tweak.tweakDefaultData {
		case let .boolean(defaultValue: defaultValue):
			let currentValue = cachedValue as? Bool ?? defaultValue
			return .boolean(value: currentValue, defaultValue: defaultValue)
		case let .integer(defaultValue: defaultValue, min: min, max: max, stepSize: step):
			let currentValue = cachedValue as? Int ?? defaultValue
			return .integer(value: currentValue, defaultValue: defaultValue, min: min, max: max, stepSize: step)
		case let .float(defaultValue: defaultValue, min: min, max: max, stepSize: step):
			let currentValue = cachedValue as? CGFloat ?? defaultValue
			return .float(value: currentValue, defaultValue: defaultValue, min: min, max: max, stepSize: step)
		case let .doubleTweak(defaultValue: defaultValue, min: min, max: max, stepSize: step):
			let currentValue = cachedValue as? Double ?? defaultValue
			return .doubleTweak(value: currentValue, defaultValue: defaultValue, min: min, max: max, stepSize: step)
		case let .color(defaultValue: defaultValue):
			let currentValue = cachedValue as? UIColor ?? defaultValue
			return .color(value: currentValue, defaultValue: defaultValue)
		case let .string(defaultValue):
			let currentValue = cachedValue as? String ?? defaultValue
			return .string(value: currentValue, defaultValue: defaultValue)
		case let .stringList(defaultValue: defaultValue, options: options):
			let currentValue = cachedValue as? StringOption ?? defaultValue
			return .stringList(value: currentValue, defaultValue: defaultValue, options: options)
		case let .action(defaultValue: defaultValue):
			let currentValue = cachedValue as? TweakAction ?? defaultValue
			return .action(value: currentValue)
		}
	}
	
	internal func setValue<T>(_ value: T?, forTweak tweak: Tweak<T>) {
		let anyTweak = AnyTweak(tweak: tweak)
		persistence.setValue(value, forTweakIdentifiable: anyTweak)
		updateBindingsForTweak(anyTweak)
	}

	internal func setValue(_ viewData: TweakViewData, forTweak tweak: AnyTweak) {
		persistence.setValue(viewData.value, forTweakIdentifiable: tweak)
		updateBindingsForTweak(tweak)
	}


	// MARK - Private

	private func updateBindingsForTweak(_ tweak: AnyTweak) {
		// Find any 1-to-1 bindings and update them
		let anyTweak = AnyTweak(tweak: tweak)
		tweakBindings[anyTweak]?.forEach {
			$0.applyBindingWithValue(currentViewDataForTweak(tweak).value)
		}

		// Find any cluster bindings and update them
		for (tweakSet, bindingsArray) in tweakSetBindings {
			if tweakSet.contains(tweak) {
				bindingsArray.forEach { $0.applyBinding() }
			}
		}
	}
}

extension TweakStore {
	internal var sortedTweakCollections: [TweakCollection] {
		return tweakCollections
			.sorted { $0.0 < $1.0 }
			.map { return $0.1 }
	}
}
