//
//  HapticsPlayer.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/2/18.
//  Copyright © 2018 Khan Academy. All rights reserved.
//

import UIKit

/// A wrapper around UIFeedbackGenerators, to more-easily support haptics in SwiftTweaks.
internal class HapticsPlayer {
	private let notificationGenerator = UINotificationFeedbackGenerator()

	func prepare() {
		self.notificationGenerator.prepare()
	}

	func playNotificationSuccess() {
		self.notificationGenerator.notificationOccurred(.success)
	}
}
