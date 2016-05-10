//
//  TweakWindow.swift
//  KATweak
//
//  Created by Bryan Clark on 11/4/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

/// A UIWindow that handles the presentation and dismissal of a TweaksViewController automatically.
/// By default, the SwiftTweaks UI appears when you shake your device - but you can supply an alternate gesture, too!
/// If you'd prefer to not use this, you can also init and present a TweaksViewController yourself.
@objc public final class TweakWindow: UIWindow {

	public enum GestureType {
		case Shake
		case Gesture(UIGestureRecognizer)
	}

	/// The amount of time you need to shake your device to bring up the Tweaks UI
	private static let shakeWindowTimeInterval: Double = 0.4

	/// The GestureType used to determine when to present the UI.
	private let gestureType: GestureType

	/// By holding on to the TweaksViewController, we get easy state restoration!
	private var tweaksViewController: TweaksViewController! // requires self for init

	/// Represents the "floating tweaks UI"
	private var floatingTweakGroupUIWindow: HitTransparentWindow?
	private let tweakStore: TweakStore

	/// We need to know if we're running in the simulator (because shake gestures don't have a time duration in the simulator)
	private let runningInSimulator: Bool

	/// Whether or not the device is shaking. Used in determining when to present the Tweaks UI when the device is shaken.
	private var shaking: Bool = false

	private var shouldPresentTweaks: Bool {
		if tweakStore.enabled {
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

		self.tweakStore = tweakStore

		// Are we running on a Mac? If so, then we're in a simulator!
		#if (arch(i386) || arch(x86_64))
			self.runningInSimulator = true
		#else
			self.runningInSimulator = false
		#endif

		super.init(frame: frame)

		tintColor = AppTheme.Colors.controlTinted

		switch gestureType {
		case .Gesture(let gestureRecognizer):
			gestureRecognizer.addTarget(self, action: #selector(self.presentTweaks))
		case .Shake:
			break
		}

		tweaksViewController = TweaksViewController(tweakStore: tweakStore, delegate: self)
		tweaksViewController.floatingTweaksWindowPresenter = self
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

	private func dismissTweaks(completion: (() -> ())? = nil) {
		tweaksViewController.dismissViewControllerAnimated(true, completion: completion)
	}
}

extension TweakWindow: TweaksViewControllerDelegate {
	public func tweaksViewControllerRequestsDismiss(tweaksViewController: TweaksViewController, completion: (() -> ())? = nil) {
		dismissTweaks(completion)
	}
}

extension TweakWindow: FloatingTweaksWindowPresenter {

	private static let presentationDuration: Double = 0.2
	private static let presentationDamping: CGFloat = 0.8
	private static let presentationVelocity: CGFloat = 5

	private static let dismissalDuration: Double = 0.2


	/// Presents a floating TweakGroup over your app's UI, so you don't have to hop in and out of the full-modal Tweak UI.
	internal func presentFloatingTweaksUIForTweakGroup(tweakGroup: TweakGroup) {
		if (floatingTweakGroupUIWindow == nil) {
			let window = HitTransparentWindow()
			window.frame = UIScreen.mainScreen().bounds
			window.backgroundColor = UIColor.clearColor()

			let floatingTweakGroupFrame = CGRect(
				origin: CGPoint(
					x: FloatingTweakGroupViewController.margins,
					y: window.frame.size.height - FloatingTweakGroupViewController.height - FloatingTweakGroupViewController.margins
				),
				size: CGSize(
					width: window.frame.size.width - FloatingTweakGroupViewController.margins*2,
					height: FloatingTweakGroupViewController.height
				)
			)

			let floatingTweaksVC = FloatingTweakGroupViewController(frame: floatingTweakGroupFrame, tweakStore: tweakStore, presenter: self)
			floatingTweaksVC.tweakGroup = tweakGroup
			window.rootViewController = floatingTweaksVC
			window.addSubview(floatingTweaksVC.view)

			window.alpha = 0
			let initialWindowFrame = CGRectOffset(window.frame, 0, floatingTweaksVC.view.bounds.height)
			let destinationWindowFrame = window.frame
			window.makeKeyAndVisible()
			floatingTweakGroupUIWindow = window

			window.frame = initialWindowFrame
			UIView.animateWithDuration(
				TweakWindow.presentationDuration,
				delay: 0,
				usingSpringWithDamping: TweakWindow.presentationDamping,
				initialSpringVelocity: TweakWindow.presentationVelocity,
				options: .BeginFromCurrentState,
				animations: { 
					window.frame = destinationWindowFrame
					window.alpha = 1
				},
				completion: nil
			)
		}
	}

	/// Dismisses the floating TweakGroup
	func dismissFloatingTweaksUI() {

		guard let floatingTweakGroupUIWindow = floatingTweakGroupUIWindow else { return }

		UIView.animateWithDuration(
			TweakWindow.dismissalDuration,
			delay: 0,
			options: .CurveEaseIn,
			animations: { 
				floatingTweakGroupUIWindow.alpha = 0
				floatingTweakGroupUIWindow.frame = CGRectOffset(floatingTweakGroupUIWindow.frame, 0, floatingTweakGroupUIWindow.frame.height)
			},
			completion: { _ in
				floatingTweakGroupUIWindow.hidden = true
				self.floatingTweakGroupUIWindow = nil
			}
		)
	}
}