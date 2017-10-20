//
//  Clip.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/19/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

/// Clips a value to be between the given min / max values, if provided.
internal func clip<U: Comparable>(_ value: U, _ minimum: U?, _ maximum: U?) -> U {
	var result = value

	if let minimum = minimum {
		result = max(minimum, result)
	}

	if let maximum = maximum {
		result = min(maximum, result)
	}

	return result
}
