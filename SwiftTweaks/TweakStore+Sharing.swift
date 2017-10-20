//
//  TweakStore+Sharing.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/19/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal extension TweakStore {
	internal var textRepresentation: String {
		// Let's sort our tweaks by collection/group/name, and then return the list!
		let returnValue: String = sortedTweakCollections
			.reduce([]) { $0 + $1.allTweaks }
			.map {
				let (stringValue, differs) = currentViewDataForTweak($0).stringRepresentation
				let linePrefix = differs ? "* " : ""
				return "\(linePrefix)\($0.tweakIdentifier) = \(stringValue)"
			}.reduce("Here are your tweaks!\nA * indicates a tweaked value.") { $0 + "\n\n" + $1 }
		return returnValue
	}
}

@objc internal class TweakStoreActivityItemSource: NSObject {
	fileprivate let textRepresentation: String

	init(text: String) {
		self.textRepresentation = text
	}
}

extension TweakStoreActivityItemSource: UIActivityItemSource {
	@objc func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
		return textRepresentation
	}

	@objc func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
		return "SwiftTweaks Backup"
	}

	@objc func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
		return textRepresentation
	}
}
