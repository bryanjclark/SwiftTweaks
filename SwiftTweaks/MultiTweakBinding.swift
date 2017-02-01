//
//  MultiTweakBinding.swift
//  SwiftTweaks
//
//  Created by Mathijs Kadijk on 31-10-16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

/// Represents a closure that should be run whenever any of the Tweaks changes.
internal struct MultiTweakBinding {
	let identifier: MultiTweakBindingIdentifier
	private let binding: () -> Void

	init(tweakSet: Set<AnyTweak>, binding: @escaping () -> Void) {
		self.identifier = MultiTweakBindingIdentifier(tweakSet: tweakSet)
		self.binding = binding
	}

	func applyBinding() {
		binding()
	}
}
