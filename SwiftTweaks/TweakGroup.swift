//
//  TweakGroup.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/10/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

internal struct TweakGroup {
	let title: String
	var tweaks: [String: AnyTweak] = [:]

	init(title: String) {
		self.title = title
	}
}

extension TweakGroup {
	internal var sortedTweaks: [AnyTweak] {
		return tweaks
			.sort { $0.0 < $1.0 }
			.map { return $0.1 }
	}
}

