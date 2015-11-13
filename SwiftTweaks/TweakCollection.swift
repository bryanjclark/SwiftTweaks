//
//  TweakCollection.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/10/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

internal struct TweakCollection {
	let title: String
	var tweakGroups: [String: TweakGroup] = [:]

	init(title: String) {
		self.title = title
	}
}

extension TweakCollection {
	internal var sortedTweakGroups: [TweakGroup] {
		return tweakGroups
			.sort { $0.0 < $1.0 }
			.map { return $0.1 }
	}

	internal var numberOfTweaks: Int {
		return sortedTweakGroups.reduce(0) { $0 + $1.sortedTweaks.count }
	}
}
