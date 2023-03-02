//
//  TweakLibrary.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/6/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

/// Create a public struct in your application that conforms to this protocol to declare your own tweaks!
public protocol TweakLibraryType {
	static var defaultStore: TweakStore { get }
}

public extension TweakLibraryType {
	/// Returns the current value for a tweak from the TweakLibrary's default store.
	static func assign<T>(_ tweak: Tweak<T>) -> T {
		return self.defaultStore.currentValueForTweak(tweak)
	}

	/// Immediately binds the currentValue of a given tweak, and then continues to update whenever the tweak changes.
	static func bind<T>(_ tweak: Tweak<T>, binding: @escaping (T) -> Void) -> TweakBindingIdentifier {
		return self.defaultStore.bind(tweak, binding: binding)
	}

	/// Unbinds the identified binding, stops delivering updates and releases the closure.
	static func unbind(identifier: TweakBindingIdentifier) {
		self.defaultStore.unbind(identifier)
	}

	/// Similar to `Combine.Subscribers.Assign`. returns nothing, since it doesn't strongly capture `on: OwnerObject`. example usage is:
	/// `ExampleTweaks.bindWeakly(ExampleTweaks.colorTint, to: \.exampleButton.backgroundColor, on: self)`
	static func bindWeakly<T, OwnerObject: AnyObject>(_ tweak: Tweak<T>, to keypath: ReferenceWritableKeyPath<OwnerObject, T>, on owner: OwnerObject) {
		self.defaultStore.bindWeakly(tweak, to: keypath, on: owner)
	}

	//  Accepts a collection of Tweaks, and immediately calls the updateHandler.
	/// The updateHandler is then re-called each time any of the collection's tweaks change.
	/// Inside the updateHandler, you'll need to use `assign` to get the tweaks' current values.
	static func bindMultiple(_ tweaks: [TweakType], binding: @escaping () -> Void) -> MultiTweakBindingIdentifier {
		return self.defaultStore.bindMultiple(tweaks, binding: binding)
	}

	/// Unbinds the identified binding, stops delivering updates and releases the closure.
	static func unbindMultiple(identifier: MultiTweakBindingIdentifier) {
		self.defaultStore.unbindMultiple(identifier)
	}
	
	static func overrideValue<T>(_ tweak: Tweak<T>, value: T?) {
		self.defaultStore.setValue(value, forTweak: tweak)
	}
}
