//
//  UIEdgeInsets+EdgeInsetsTweakTemplate.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/8/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
	init(edgeInsetsTweakTemplate: EdgeInsetsTweakTemplate, fromTweakStore tweakStore: TweakStore) {
		self.init(
			top: tweakStore.assign(edgeInsetsTweakTemplate.top),
			left: tweakStore.assign(edgeInsetsTweakTemplate.left),
			bottom: tweakStore.assign(edgeInsetsTweakTemplate.bottom),
			right: tweakStore.assign(edgeInsetsTweakTemplate.right)
		)
	}
}