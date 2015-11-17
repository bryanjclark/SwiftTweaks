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

	public var collectionName: String { return tweak.collectionName }
	public var groupName: String { return tweak.groupName }
	public var tweakName: String { return tweak.tweakName }

	public var tweakViewDataType: TweakViewDataType { return tweak.tweakViewDataType }
	public var tweakDefaultData: TweakDefaultData { return tweak.tweakDefaultData }

	public init(tweak: TweakType) {
		self.tweak = tweak.tweak
	}
}

/// When combined with AnyTweak, this provides our type-erasure around Tweak<T>
public protocol TweakType {
	var tweak: TweakType { get }

	var collectionName: String { get }
	var groupName: String { get }
	var tweakName: String { get }

	var tweakViewDataType: TweakViewDataType { get }
	var tweakDefaultData: TweakDefaultData { get }
}

/// Extend AnyTweak to support identification in persistence
extension AnyTweak: TweakIdentifiable {
	var persistenceIdentifier: String {
		return "\(collectionName)|\(groupName)|\(tweakName)"
	}
}

/*
backupName: CoolBackup

nacho|cool|tweak: F(0.5)
nacho|other|tweak: B(t)
nacho|other|tweak2: #FF00FF00

*/

// mybackup.swifttweakbackup