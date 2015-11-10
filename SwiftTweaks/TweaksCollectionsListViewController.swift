//
//  TweaksCollectionsListViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/9/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal protocol TweaksCollectionsListViewControllerDelegate {
	func tweaksCollectionsListViewControllerDidTapDismissButton(tweaksCollectionsListViewController: TweaksCollectionsListViewController)
}

internal class TweaksCollectionsListViewController: UIViewController {
	private let tableView: UITableView
	private let tweakStore: TweakStore

	internal var delegate: TweaksCollectionsListViewControllerDelegate?

	internal init(tweakStore: TweakStore) {
		self.tweakStore = tweakStore

		self.tableView = UITableView(frame: CGRectZero, style: .Plain)

		super.init(nibName: nil, bundle: nil)

		view.addSubview(tableView)

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .Plain, target: self, action: "resetStore")
		navigationItem.leftBarButtonItem?.tintColor = UIColor.redColor()

		toolbarItems = [
			UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionButtonTapped"),
			UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: "Dismiss", style: .Done, target: self, action: "dismissButtonTapped")
		]
	}

	override func viewDidLoad() {
		self.tableView.frame = view.bounds
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: Events

	@objc private func resetStore() {
		self.tweakStore.reset()

		let alert = UIAlertController(title: "Tweaks Reset", message: "Tweaks have been reset to their default values.", preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
		presentViewController(alert, animated: true, completion: nil)
	}

	@objc private func dismissButtonTapped() {
		self.delegate?.tweaksCollectionsListViewControllerDidTapDismissButton(self)
	}

	@objc private func actionButtonTapped() {
		let alertController = UIAlertController(title: "Sharing Backups Not Yet Implemented", message: "Easy, tiger.", preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}
}
