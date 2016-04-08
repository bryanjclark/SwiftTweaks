//
//  TweakStoreInitializable.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/8/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

/// WIP on how to get a homogeneous array of TweakType + TweakGroupTemplate into a single array for initializing a TweakStore.
/// The gist of this idea: you could create a heterogeneous array of Tweak<T>'s and TweakGroupTemplateTypes, and use that to init TweakStore in TweakLibraryType's init method.
public struct TweakStoreInitializable {
	let anyTweaks: [AnyTweak]

	init(tweak: TweakType) {
		self.anyTweaks = [AnyTweak.init(tweak: tweak)]
	}

	init(tweakGroupTemplate: TweakGroupTemplateType) {
		self.anyTweaks = tweakGroupTemplate.tweaks
	}
}