//
//  TweakLibrary.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/6/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

/// Create a public struct in your application that conforms to this protocol to declare your own tweaks!
public protocol TweakLibraryType {
	static var defaultStore: TweakStore { get }
}

public extension TweakLibraryType {
	/// Returns the current value for a tweak from the TweakLibrary's default store.
	static func assign<T>(tweak: Tweak<T>) -> T {
		return self.defaultStore.currentValueForTweak(tweak)
	}
}

/// A type-erasure around Tweak<T>, so we can collect them together in TweakLibraryType.
public struct AnyTweak: TweakType {
	public let tweak: TweakType

	private let getValueViewData: () -> TweakViewData

	public var collectionName: String { return tweak.collectionName }
	public var groupName: String { return tweak.groupName }
	public var tweakName: String { return tweak.tweakName }

	public var tweakViewType: TweakViewType { return tweak.tweakViewType }
	public var tweakViewData: TweakViewData { return tweak.tweakViewData }


	public init(tweak: TweakType) {
		self.tweak = tweak.tweak
		self.getValueViewData = { return tweak.tweakViewData }
	}


}

/// When combined with AnyTweak, this provides our type-erasure around Tweak<T>
public protocol TweakType {
	var tweak: TweakType { get }

	var collectionName: String { get }
	var groupName: String { get }
	var tweakName: String { get }

	var tweakViewType: TweakViewType { get }
	var tweakViewData: TweakViewData { get }
}