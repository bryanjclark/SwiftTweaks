//
//  TweakStore+Sharing.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/19/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal extension TweakStore {
	var textRepresentation: String {
		let prefix = """
		Here are your tweaks!
		(A * indicates a tweaked value.)
		"""

		// Let's sort our tweaks by collection/group/name, and then return the list!
		let returnValue: String = sortedTweakCollections
			.reduce([]) { $0 + $1.allTweaks }
			.filter { $0.tweakViewDataType.stringRepresentable }
			.map {
				let (stringValue, differs) = currentViewDataForTweak($0).stringRepresentation
				let linePrefix = differs ? "* " : ""
				return "\(linePrefix)\($0.tweakIdentifier) = \(stringValue)"
			}.reduce(prefix) { $0 + "\n\n" + $1 }
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

	@objc func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
		return "SwiftTweaks Backup"
	}

	@objc func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
		return textRepresentation
	}
}

fileprivate extension TweakViewDataType {
	/// Whether the tweak can be represented as a string
	/// If false, then the tweak is excluded in TweakStore.textRepresentation
	/// (e.g. avoid cluttering the textRepresentation with .action tweaks, which aren't meaningful there!)
	var stringRepresentable: Bool {
		switch self {
		case .action:
			return false
		case .boolean, .integer, .cgFloat, .double, .uiColor, .string, .stringList:
			return true
		}
	}
}
