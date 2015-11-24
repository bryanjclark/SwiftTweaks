//
//  TweakWindow.swift
//  KATweak
//
//  Created by Bryan Clark on 11/4/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

/// A UIWindow that handles the presentation and dismissal of a TweaksViewController automatically
@objc public class TweakWindow: UIWindow {

	public enum GestureType {
		case Shake
		case Gesture(UIGestureRecognizer)
	}

	/// The amount of time you need to shake your device to bring up the Tweaks UI
	private static let shakeWindowTimeInterval: Double = 0.4

	private let gestureType: GestureType

	/// By holding on to the TweaksViewController, we get easy state restoration!
	private let tweaksViewController: TweaksViewController
	private let tweaksEnabled: Bool

	/// We need to know if we're running in the simulator (because shake gestures don't have a time duration in the simulator)
	private let runningInSimulator: Bool

	private var shaking: Bool = false

	private var shouldPresentTweaks: Bool {

		if tweaksEnabled {
			switch gestureType {
			case .Shake: return shaking || runningInSimulator
			case .Gesture: return true
			}
		} else {
			return false
		}
	}

	// MARK: Init

	public init(frame: CGRect, gestureType: GestureType = .Shake, tweakStore: TweakStore) {
		self.gestureType = gestureType

		self.tweaksViewController = TweaksViewController(tweakStore: tweakStore)
		self.tweaksEnabled = tweakStore.enabled

		// Are we running on a Mac? If so, then we're in a simulator!
		#if (arch(i386) || arch(x86_64))
			self.runningInSimulator = true
		#else
			self.runningInSimulator = false
		#endif

		super.init(frame: frame)

		switch gestureType {
		case .Gesture(let gestureRecognizer):
			gestureRecognizer.addTarget(self, action: "presentTweaks")
		case .Shake:
			break
		}

		tweaksViewController.delegate = self
	}

	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	// MARK: Shaking & Gestures
	public override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
		if motion == .MotionShake {
			shaking = true
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(TweakWindow.shakeWindowTimeInterval * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
				if self.shouldPresentTweaks {
					self.presentTweaks()
				}
			}
		}

		super.motionBegan(motion, withEvent: event)
	}

	public override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
		if motion == .MotionShake {
			shaking = false
		}

		super.motionEnded(motion, withEvent: event)
	}


	// MARK: Presenting & Dismissing

	@objc private func presentTweaks() {

		guard let rootViewController = rootViewController else {
			return
		}

		var visibleViewController = rootViewController
		while (visibleViewController.presentedViewController != nil) {
			visibleViewController = visibleViewController.presentedViewController!
		}

		if !(visibleViewController is TweaksViewController) {
			visibleViewController.presentViewController(tweaksViewController, animated: true, completion: nil)
		}

	}

	private func dismissTweaks() {
		tweaksViewController.dismissViewControllerAnimated(true, completion: nil)
	}
}

extension TweakWindow: TweaksViewControllerDelegate {
	public func tweaksViewControllerPressedDismiss(tweaksViewController: TweaksViewController) {
		dismissTweaks()
	}
}