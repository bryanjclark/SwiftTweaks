//
//  TweaksViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/5/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

public protocol TweaksViewControllerDelegate {
	func tweaksViewControllerPressedDismiss(tweaksViewController: TweaksViewController)
}

public class TweaksViewController: UIViewController {

	private let tweakStore: TweakStore

	private let navController: UINavigationController
	private let segmentedControl: UISegmentedControl = {
		let tweaksTitle = NSLocalizedString("Tweaks", comment: "Segmented Control title for tweaks.")
		let backupsTitle = NSLocalizedString("Backups", comment: "Segmented Control title for backups.")
		return UISegmentedControl(items: [tweaksTitle, backupsTitle])
	}()

	public var delegate: TweaksViewControllerDelegate?

	internal static let dismissButtonTitle = NSLocalizedString("Dismiss", comment: "Button to dismiss TweaksViewController.")

	public init(tweakStore: TweakStore) {
		self.tweakStore = tweakStore

		let tweaksCollectionsVC = TweaksCollectionsListViewController(tweakStore: tweakStore)
		self.navController = UINavigationController(rootViewController: tweaksCollectionsVC)

		super.init(nibName: nil, bundle: nil)

		segmentedControl.addTarget(self, action: "segmentedControlDidChange:", forControlEvents: .ValueChanged)
		segmentedControl.selectedSegmentIndex = 0

		tweaksCollectionsVC.navigationItem.titleView = segmentedControl
		tweaksCollectionsVC.delegate = self

		navController.toolbarHidden = false
		view.addSubview(navController.view)
	}

	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: Handling Segmented Control


	@objc private func segmentedControlDidChange(sender: UISegmentedControl) {
		assert(sender == segmentedControl)
		print("segmentedControl did change: \(segmentedControl.selectedSegmentIndex)")
	}
}

extension TweaksViewController: TweaksCollectionsListViewControllerDelegate {
	func tweaksCollectionsListViewControllerDidTapDismissButton(tweaksCollectionsListViewController: TweaksCollectionsListViewController) {
		self.delegate?.tweaksViewControllerPressedDismiss(self)
	}
}
