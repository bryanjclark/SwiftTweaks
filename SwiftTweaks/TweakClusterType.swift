//
//  TweakClusterType.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/8/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

/// This protocol allows for easy initialization of TweakStore.
/// It allows you to combine one-off Tweak<T>'s with TweakGroupTemplates into a single array without hassle.
/// (For example, a single Tweak can conform by returning itself wrapped in an array!)
public protocol TweakClusterType {
	var tweakCluster: [AnyTweak] { get }
}