//
//  Clip.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/19/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

func clip<U: SignedNumberType>(var value: U, _ minimum: U?, _ maximum: U?) -> U {
	if let minimum = minimum {
		value = max(minimum, value)
	}

	if let maximum = maximum {
		value = min(maximum, value)
	}

	return value
}