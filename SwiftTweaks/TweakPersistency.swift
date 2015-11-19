//
//  TweakPersistency.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/16/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

/// Identifies tweaks in TweakPersistency
internal protocol TweakIdentifiable {
	var persistenceIdentifier: String { get }
}

/// Caches Tweak values
internal typealias TweakCache = [String: TweakableType]


/// Persists state for tweaks in a TweakCache
internal class TweakPersistency {
	private let diskPersistency: TweakDiskPersistency

	private var tweakCache: TweakCache = [:]

	init(identifier: String) {
		self.diskPersistency = TweakDiskPersistency(identifier: identifier)
		self.tweakCache = self.diskPersistency.loadFromDisk()
	}

	func currentValueForTweak<T>(tweak: Tweak<T>) -> T? {
		return currentValueForTweakIdentifiable(AnyTweak(tweak: tweak)) as? T
	}

	func currentValueForTweakIdentifiable(tweakID: TweakIdentifiable) -> TweakableType? {
		return tweakCache[tweakID.persistenceIdentifier]
	}

	func setValue(value: TweakableType?,  forTweakIdentifiable tweakID: TweakIdentifiable) {
		tweakCache[tweakID.persistenceIdentifier] = value
		self.diskPersistency.saveToDisk(tweakCache)
	}

	func clearAllData() {
		tweakCache = [:]
		self.diskPersistency.saveToDisk(tweakCache)
	}
}

/// Persists a TweakCache on disk using NSCoding
private class TweakDiskPersistency {
	private let fileURL: NSURL

	private static func fileURLForIdentifier(identifier: String) -> NSURL {
		return try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
			.URLByAppendingPathComponent("SwiftTweaks")
			.URLByAppendingPathComponent("\(identifier)")
			.URLByAppendingPathExtension("db")
	}

	private let queue = dispatch_queue_create("org.khanacademy.swift_tweaks.disk_persistency", DISPATCH_QUEUE_SERIAL)

	init(identifier: String) {
		self.fileURL = TweakDiskPersistency.fileURLForIdentifier(identifier)
		self.ensureDirectoryExists()
	}

	/// Creates a directory (if needed) for our persisted TweakCache on disk
	private func ensureDirectoryExists() {
		dispatch_async(self.queue) {
			try! NSFileManager.defaultManager().createDirectoryAtURL(self.fileURL.URLByDeletingLastPathComponent!, withIntermediateDirectories: true, attributes: nil)
		}
	}

	func loadFromDisk() -> TweakCache {
		var result: TweakCache!

		dispatch_sync(self.queue) {
			result = NSData(contentsOfURL: self.fileURL)
				.flatMap(NSKeyedUnarchiver.unarchiveObjectWithData)
				.flatMap { $0 as? Data }
				.map { $0.cache }
				?? [:]
		}

		return result
	}

	func saveToDisk(data: TweakCache) {
		dispatch_async(self.queue) {
			let nsData = NSKeyedArchiver.archivedDataWithRootObject(Data(cache: data))
			nsData.writeToURL(self.fileURL, atomically: true)
		}
	}

	/// Implements NSCoding for TweakCache.
	/// TweakCache a flat dictionary: [String: TweakableType]. 
	/// However, because re-hydrating TweakableType from its underlying NSNumber gets Bool & Int mixed up, we have to persist a different structure on disk: [TweakViewDataType: [String: AnyObject]]
	/// This ensures that if something was saved as a Bool, it's read back as a Bool.
	@objc private final class Data: NSObject, NSCoding {
		let cache: TweakCache

		init(cache: TweakCache) {
			self.cache = cache
		}

		@objc convenience init?(coder aDecoder: NSCoder) {
			var cache: TweakCache = [:]

			// Read through each TweakViewDataType...
			for dataType in TweakViewDataType.allTypes {
				// If a sub-dictionary exists for that type,
				if let dataTypeDictionary = aDecoder.decodeObjectForKey(dataType.nsCodingKey) as? Dictionary<String, AnyObject> {
					// Read through each entry and populate the cache
					for (key, value) in dataTypeDictionary {
						if let value = Data.tweakableTypeWithAnyObject(value, withType: dataType) {
							cache[key] = value
						}
					}
				}
			}

			self.init(cache: cache)
		}

		@objc private func encodeWithCoder(aCoder: NSCoder) {

			// Our "dictionary of dictionaries" that is persisted on disk
			var diskPersistedDictionary: [TweakViewDataType : [String: AnyObject]] = [:]

			// For each thing in our TweakCache,
			for (key, value) in cache {
				let dataType = value.dynamicType.tweakViewDataType

				// ... create the "sub-dictionary" if it doesn't already exist for a particular TweakViewDataType
				if diskPersistedDictionary[dataType] == nil {
					diskPersistedDictionary[dataType] = [:]
				}

				// ... and set the cached value inside the sub-dictionary.
				diskPersistedDictionary[dataType]![key] = value.nsCoding
			}

			// Now we persist the "dictionary of dictionaries" on disk!
			for (key, value) in diskPersistedDictionary {
				aCoder.encodeObject(value, forKey: key.nsCodingKey)
			}
		}

		// Reads from the cache, casting to the appropriate TweakViewDataType
		private static func tweakableTypeWithAnyObject(anyObject: AnyObject, withType type: TweakViewDataType) -> TweakableType? {
			switch type {
			case .Integer: return anyObject as? Int
			case .Boolean: return anyObject as? Bool
			case .CGFloat: return anyObject as? CGFloat
			case .Double: return anyObject as? Double
			case .UIColor: return anyObject as? UIColor
			}
		}
	}
}

private extension TweakViewDataType {
	/// Identifies our TweakViewDataType when in NSCoding. See implementation of TweakDiskPersistency.Data
	var nsCodingKey: String {
		switch self {
		case .Boolean: return "boolean"
		case .Integer: return "integer"
		case .CGFloat: return "cgfloat"
		case .Double: return "double"
		case .UIColor: return "uicolor"
		}
	}
}

private extension TweakableType {
	/// Gets the underlying value from a Tweakable Type
	var nsCoding: AnyObject {
		switch self.dynamicType.tweakViewDataType {
			case .Boolean: return self as! Bool
			case .Integer: return self as! Int
			case .CGFloat: return self as! CGFloat
			case .Double: return self as! Double
			case .UIColor: return self as! UIColor
		}
	}
}
