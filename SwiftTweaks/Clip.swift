//
//  Clip.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/19/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

internal func clip<U: SignedNumberType>(value: U, _ minimum: U?, _ maximum: U?) -> U {
	var result = value

	if let minimum = minimum {
		result = max(minimum, value)
	}

	if let maximum = maximum {
		result = min(maximum, value)
	}

	return result
}

extension Tweak where T: SignedNumberType {
	internal func clipIfSignedNumberType(value: T) -> T {
		return clip(value, minimumValue, maximumValue)
	}
}

extension Tweak {
	internal func clipIfSignedNumberType(value: T) -> T {
		/// Since we're not a SignedNumberType, this just returns the value.
		return value
	}
}