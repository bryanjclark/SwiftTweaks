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
		/// Shake the device, like you're trying to undo some text
		case shake

		/// A commonly-used shortcut: double-tap with two fingers.
		/// In the simulator, hold down option and double-tap.
		/// SwiftTweaks handles adding the gesture to the entire TweakWindow.
		case twoFingerDoubleTap

		/// Use whatever shortcut you'd like to bring up SwiftTweaks.
		/// It's up to you to add the gesture recognizer to your UI somewhere; 
		/// (you can add the gesture to the TweakWindow right after calling TweakWindow.init if you like!)
		case gesture(UIGestureRecognizer)
	}

	/// The amount of time you need to shake your device to bring up the Tweaks UI
	private static let shakeWindowTimeInterval: Double = 0.4

	/// The GestureType used to determine when to present the UI.
	private let gestureType: GestureType

	/// By holding on to the TweaksViewController, we get easy state restoration!
	private var tweaksViewController: TweaksViewController! // requires self for init

	/// Represents the "floating tweaks UI"
	fileprivate var floatingTweakGroupUIWindow: HitTransparentWindow?
	fileprivate let tweakStore: TweakStore

	/// We need to know if we're running in the simulator (because shake gestures don't have a time duration in the simulator)
	private let runningInSimulator: Bool = {
		#if targetEnvironment(simulator)
			return true
		#else
			return false
		#endif
	}()

	/// Whether or not the device is shaking. Used in determining when to present the Tweaks UI when the device is shaken.
	private var shaking: Bool = false

	private var shouldShakePresentTweaks: Bool {
		if tweakStore.enabled {
			switch gestureType {
			case .shake: return shaking || runningInSimulator
			case .twoFingerDoubleTap, .gesture: return false
			}
		} else {
			return false
		}
	}

	// MARK: Init

	public init(frame: CGRect, gestureType: GestureType = .shake, tweakStore: TweakStore) {
		self.gestureType = gestureType
		self.tweakStore = tweakStore

		super.init(frame: frame)

		commonInit(tweakStore: tweakStore)
	}

    @available(iOS 13.0, *)
    public init(windowScene: UIWindowScene, gestureType: GestureType = .shake, tweakStore: TweakStore) {
        self.gestureType = gestureType
        self.tweakStore = tweakStore

        super.init(windowScene: windowScene)

		commonInit(tweakStore: tweakStore)
    }
	
	private func commonInit(tweakStore: TweakStore) {
        tintColor = AppTheme.Colors.controlTinted

        if tweakStore.enabled {
            switch gestureType {
            case .gesture(let gestureRecognizer):
                gestureRecognizer.addTarget(self, action: #selector(self.presentTweaks))
            case .twoFingerDoubleTap:
                let twoFingerDoubleTapGesture = UITapGestureRecognizer()
                twoFingerDoubleTapGesture.numberOfTapsRequired = 2
                twoFingerDoubleTapGesture.numberOfTouchesRequired = 2
                twoFingerDoubleTapGesture.addTarget(self, action: #selector(self.presentTweaks))
                self.addGestureRecognizer(twoFingerDoubleTapGesture)
            case .shake:
                break
            }
        }

        tweaksViewController = TweaksViewController(tweakStore: tweakStore, delegate: self)
        tweaksViewController.floatingTweaksWindowPresenter = self
	}

	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	// MARK: Shaking & Gestures
	public override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			shaking = true
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(TweakWindow.shakeWindowTimeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
				if self.shouldShakePresentTweaks {
					self.presentTweaks()
				}
			}
		}

		super.motionBegan(motion, with: event)
	}

	public override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			shaking = false
		}

		super.motionEnded(motion, with: event)
	}


	// MARK: Presenting & Dismissing

	@objc private func presentTweaks() {
		guard let rootViewController = rootViewController else {
			return
		}

		guard self.tweakStore.enabled else {
			return
		}

		var visibleViewController = rootViewController
		while (visibleViewController.presentedViewController != nil) {
			visibleViewController = visibleViewController.presentedViewController!
		}

		if !(visibleViewController is TweaksViewController) {
			switch visibleViewController.traitCollection.horizontalSizeClass {
			case .compact, .unspecified:
				visibleViewController.present(tweaksViewController, animated: true, completion: nil)
			case .regular:
				tweaksViewController.modalPresentationStyle = .formSheet
				visibleViewController.present(tweaksViewController, animated: true, completion: nil)
			@unknown default:
				return
			}

		}

	}

	fileprivate func dismissTweaks(_ completion: (() -> ())? = nil) {
		tweaksViewController.dismiss(animated: true, completion: completion)
	}
}

extension TweakWindow: TweaksViewControllerDelegate {
	public func tweaksViewControllerRequestsDismiss(_ tweaksViewController: TweaksViewController, completion: (() -> ())? = nil) {
		dismissTweaks(completion)
	}
}

extension TweakWindow: FloatingTweaksWindowPresenter {

	private static let presentationDuration: Double = 0.2
	private static let presentationDamping: CGFloat = 0.8
	private static let presentationVelocity: CGFloat = 5

	private static let dismissalDuration: Double = 0.2


	/// Presents a floating TweakGroup over your app's UI, so you don't have to hop in and out of the full-modal Tweak UI.
	internal func presentFloatingTweaksUI(forTweakGroup tweakGroup: TweakGroup) {
		guard floatingTweakGroupUIWindow == nil else { return }

		let window = HitTransparentWindow()
		window.frame = UIScreen.main.bounds
		window.backgroundColor = UIColor.clear

		var originY = window.frame.size.height - FloatingTweakGroupViewController.height - FloatingTweakGroupViewController.margins
		if #available(iOS 11.0, *) {
			originY = originY - self.safeAreaInsets.bottom
		}

		let floatingTweakGroupFrame = CGRect(
			origin: CGPoint(
				x: FloatingTweakGroupViewController.margins,
				y: originY
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
		let destinationWindowFrame = floatingTweaksVC.view.frame
		let initialWindowFrame = destinationWindowFrame.offsetBy(dx: 0, dy: floatingTweaksVC.view.bounds.height)
		window.makeKeyAndVisible()
		floatingTweakGroupUIWindow = window

		window.frame = initialWindowFrame
		UIView.animate(
			withDuration: TweakWindow.presentationDuration,
			delay: 0,
			usingSpringWithDamping: TweakWindow.presentationDamping,
			initialSpringVelocity: TweakWindow.presentationVelocity,
			options: .beginFromCurrentState,
			animations: {
				window.frame = destinationWindowFrame
				window.alpha = 1
			},
			completion: nil
		)
	}

	/// Dismisses the floating TweakGroup
	func dismissFloatingTweaksUI() {
		guard let floatingTweakGroupUIWindow = floatingTweakGroupUIWindow else { return }

		UIView.animate(
			withDuration: TweakWindow.dismissalDuration,
			delay: 0,
			options: .curveEaseIn,
			animations: { 
				floatingTweakGroupUIWindow.alpha = 0
				floatingTweakGroupUIWindow.frame = floatingTweakGroupUIWindow.frame.offsetBy(dx: 0, dy: floatingTweakGroupUIWindow.frame.height)
			},
			completion: { _ in
				floatingTweakGroupUIWindow.isHidden = true
				self.floatingTweakGroupUIWindow = nil
			}
		)
	}

	func resumeDisplayingMainTweaksInterface() {
		guard floatingTweakGroupUIWindow != nil else { return }

		self.dismissFloatingTweaksUI()
		self.presentTweaks()
	}
}
