//
//  TweakBinding.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/17/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

/// Represents a Tweak and a closure that should be run whenever the Tweak changes.
internal struct TweakBinding<T: TweakableType>: TweakBindingType{
	let tweak: Tweak<T>
	let binding: (T) -> Void

	init(tweak: Tweak<T>, binding: @escaping (T) -> Void) {
		self.tweak = tweak
		self.binding = binding
	}

	func applyBindingWithValue(_ value: TweakableType) {
		switch type(of: value).tweakViewDataType {
		case .boolean, .integer, .cgFloat, .double, .uiColor:
			binding(value as! T)
		}
	}
}

// A type-erasure around TweakBinding<T>, so we can gather them together in TweakStore.tweakBindings
internal struct AnyTweakBinding: TweakBindingType {
	private let tweakBinding: TweakBindingType

	init(tweakBinding: TweakBindingType) {
		self.tweakBinding = tweakBinding
	}

	func applyBindingWithValue(_ value: TweakableType) {
		tweakBinding.applyBindingWithValue(value)
	}
}

// When combined with AnyTweakBinding, this provides our type-erasure around TweakBinding<T>
internal protocol TweakBindingType {
	func applyBindingWithValue(_ value: TweakableType)
}
