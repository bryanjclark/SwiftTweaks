//
//  HapticsPlayer.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/2/18.
//  Copyright © 2018 Khan Academy. All rights reserved.
//

import UIKit

internal protocol HapticsPlayerType {
	func prepare()
	func playNotificationSuccess()
}

/// A wrapper around UIFeedbackGenerators, to more-easily support haptics in SwiftTweaks without requiring iOS 10.
/// Plays haptics on iOS 10 and later; does nothing on earlier versions of iOS.
internal class HapticsPlayer: HapticsPlayerType {
	private let hapticsPlayer: HapticsPlayerType?

	init() {
		if #available(iOS 10.0, *) {
			self.hapticsPlayer = ActualHapticsPlayer()
		} else {
			self.hapticsPlayer = nil
		}
	}

	func prepare() {
		self.hapticsPlayer?.prepare()
	}

	func playNotificationSuccess() {
		self.hapticsPlayer?.playNotificationSuccess()
	}
}

@available(iOS 10.0, *)
/// The class that *actually* plays haptics; only available on iOS 10 and later.
fileprivate class ActualHapticsPlayer: HapticsPlayerType {
	private let notificationGenerator = UINotificationFeedbackGenerator()

	func prepare() {
		self.notificationGenerator.prepare()
	}

	func playNotificationSuccess() {
		self.notificationGenerator.notificationOccurred(.success)
	}
}



