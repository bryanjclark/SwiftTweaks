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

		let tweakRootVC = TweaksCollectionsListViewController(tweakStore: tweakStore, delegate: self)
		navController = UINavigationController(rootViewController: tweakRootVC)
		navController.isToolbarHidden = false
		navController.willMove(toParent: self)
		view.addSubview(navController.view)
		addChild(navController)
		navController.didMove(toParent: self)
	}

	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

fileprivate extension TweaksViewController {
	func displayFloatingTweakPanel(forTweakGroup tweakGroup: TweakGroup) {
		delegate.tweaksViewControllerRequestsDismiss(self) {
			self.floatingTweaksWindowPresenter?.presentFloatingTweaksUI(forTweakGroup: tweakGroup)
		}
	}
}

extension TweaksViewController: TweaksCollectionsListViewControllerDelegate {
	func tweakCollectionListViewController(
		_ tweakCollectionViewController: TweaksCollectionsListViewController,
		didTapFloatingTweakGroupButtonForTweakGroup tweakGroup: TweakGroup
	) {
		self.displayFloatingTweakPanel(forTweakGroup: tweakGroup)
	}

	func tweaksCollectionsListViewControllerDidTapDismissButton(_ tweaksCollectionsListViewController: TweaksCollectionsListViewController) {
		delegate.tweaksViewControllerRequestsDismiss(self, completion: nil)
	}

	func tweaksCollectionsListViewControllerDidTapShareButton(
		_ tweaksCollectionsListViewController: TweaksCollectionsListViewController,
		shareButton: UIBarButtonItem
	) {
		let activityVC = UIActivityViewController(
			activityItems: [TweakStoreActivityItemSource(text: tweakStore.textRepresentation)],
			applicationActivities: nil
		)
		activityVC.popoverPresentationController?.barButtonItem = shareButton
		present(activityVC, animated: true, completion: nil)
	}
}
