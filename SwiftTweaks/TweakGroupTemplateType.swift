//
//  TweakGroupTemplateType.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/8/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

/// Use this protocol to create your own commonly-used TweakGroups.
/// For example, tweaks are often used for animations, so we've built out TweakGroupTemplateSpringAnimation to make it *really* easy to tweak spring animations!
public protocol TweakGroupTemplateType: TweakClusterType {
	var collectionName: String { get }
	var groupName: String { get }
	var tweakCluster: [AnyTweak] { get }
}