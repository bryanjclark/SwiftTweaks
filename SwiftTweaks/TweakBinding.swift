//
//  TweakBinding.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/17/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

internal struct TweakBinding<T: TweakableType>: TweakBindingType{
	let tweak: Tweak<T>
	let binding: (T) -> Void

	init(tweak: Tweak<T>, binding: (T) -> Void) {
		self.tweak = tweak
		self.binding = binding
	}

	func applyBindingWithValue(value: TweakableType) {
		switch value.dynamicType.tweakViewDataType {
		case .Boolean:
			binding(value as! T)
		case .Integer:
			binding(value as! T)
		case .CGFloat:
			binding(value as! T)
		case .UIColor:
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

	func applyBindingWithValue(value: TweakableType) {
		tweakBinding.applyBindingWithValue(value)
	}
}

// When combined with AnyTweakBinding, this provides our type-erasure around TweakBinding<T>
internal protocol TweakBindingType {
	func applyBindingWithValue(value: TweakableType)
}