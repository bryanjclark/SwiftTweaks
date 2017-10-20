//
//  EdgeInsetsTweakTemplate.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/8/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation
import UIKit


/// A shortcut to create UIEdgeInsets using Tweaks.
public struct EdgeInsetsTweakTemplate: TweakGroupTemplateType {
	public let collectionName: String
	public let groupName: String

	public let top: Tweak<CGFloat>
	public let left: Tweak<CGFloat>
	public let bottom: Tweak<CGFloat>
	public let right: Tweak<CGFloat>

	public var tweakCluster: [AnyTweak] {
		return [top, left, bottom, right].map(AnyTweak.init)
	}

	private static let edgeInsetDefaultParameters = ComparableTweakDefaultParameters<CGFloat>(defaultValue: 0, minValue: 0, maxValue: nil, stepSize: 1.0)

	public init(
		_ collectionName: String,
		_ groupName: String,
		  defaultValue: UIEdgeInsets? = nil
	) {
		self.collectionName = collectionName
		self.groupName = groupName

		func createInsetTweak(_ tweakName: String, customDefaultValue: CGFloat?) -> Tweak<CGFloat> {
            return Tweak(
                collectionName: collectionName,
                groupName: groupName,
                tweakName: tweakName,
                defaultParameters: EdgeInsetsTweakTemplate.edgeInsetDefaultParameters,
                customDefaultValue: customDefaultValue
            )
		}

		self.top = createInsetTweak("Top", customDefaultValue: defaultValue?.top)
		self.left = createInsetTweak("Left", customDefaultValue: defaultValue?.left)
		self.bottom = createInsetTweak("Bottom", customDefaultValue: defaultValue?.bottom)
		self.right = createInsetTweak("Right", customDefaultValue: defaultValue?.right)
	}



}

