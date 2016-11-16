//
//  TweaksViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/5/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

public protocol TweaksViewControllerDelegate: class {
	func tweaksViewControllerRequestsDismiss(_ tweaksViewController: TweaksViewController, completion: (() -> ())?)
}

/// The main UI for Tweaks. 
/// You can init and present TweaksViewController yourself, if you'd prefer to not use TweakWindow.
public final class TweaksViewController: UIViewController {

	private let tweakStore: TweakStore

	private var navController: UINavigationController! // self required for init

	public unowned var delegate: TweaksViewControllerDelegate
	internal var floatingTweaksWindowPresenter: FloatingTweaksWindowPresenter?

	internal static let dismissButtonTitle = NSLocalizedString("Dismiss", comment: "Button to dismiss TweaksViewController.")

	public init(tweakStore: TweakStore, delegate: TweaksViewControllerDelegate) {
		self.tweakStore = tweakStore
		self.delegate = delegate

		super.init(nibName: nil, bundle: nil)

		let tweakRootVC = TweaksRootViewController(tweakStore: tweakStore, delegate: self)
		navController = UINavigationController(rootViewController: tweakRootVC)
		navController.isToolbarHidden = false
		view.addSubview(navController.view)
	}

	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension TweaksViewController: TweaksRootViewControllerDelegate {
	internal func tweaksRootViewControllerDidPressDismissButton(_ tweaksRootViewController: TweaksRootViewController) {
		delegate.tweaksViewControllerRequestsDismiss(self, completion: nil)
	}

	internal func tweaksRootViewController(_ tweaksRootViewController: TweaksRootViewController, requestsFloatingUIForTweakGroup tweakGroup: TweakGroup) {
		delegate.tweaksViewControllerRequestsDismiss(self) {
			self.floatingTweaksWindowPresenter?.presentFloatingTweaksUI(forTweakGroup: tweakGroup)
		}
	}
}
