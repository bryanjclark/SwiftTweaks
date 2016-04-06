//
//  Clip.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/19/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

func clip<U: SignedNumberType>(value: U, _ minimum: U?, _ maximum: U?) -> U {
	var result = value

	if let minimum = minimum {
		result = max(minimum, value)
	}

	if let maximum = maximum {
		result = min(maximum, value)
	}

	return result
}