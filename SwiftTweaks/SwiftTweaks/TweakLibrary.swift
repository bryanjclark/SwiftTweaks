//
//  TweakLibrary.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/6/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

/// Allows our Tweak UI to know about all the available tweaks in a collection.
/// Create a struct that conforms to this protocol to declare your own tweaks!
public protocol TweakLibraryType {
	static var defaultStore: TweakStore { get }
}

extension TweakLibraryType {
	static func assign<T>(tweak: Tweak<T>) -> T {
		return self.defaultStore.currentValueForTweak(tweak)
	}
}

/// A type-erasure around Tweak<T>, so we can collect them together in TweakLibraryType
public struct AnyTweak: TweakType {
	public let tweak: TweakType
	public var collectionName: String { return tweak.collectionName }
	public var groupName: String { return tweak.groupName }
	public var tweakName: String { return tweak.tweakName }

	public static func arrayOfAnyTweakFromArrayOfTweakTypes(tweakTypes: [TweakType]) -> [AnyTweak] {
		return tweakTypes.map { AnyTweak(tweak: $0) }
	}
}

/// When combined with AnyTweak, this provides our type-erasure around Tweak<T>
public protocol TweakType {
	var collectionName: String { get }
	var groupName: String { get }
	var tweakName: String { get }
	var tweak: TweakType { get }
}