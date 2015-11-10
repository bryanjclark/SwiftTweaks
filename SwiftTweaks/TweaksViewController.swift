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

	public var delegate: TweaksViewControllerDelegate?

	private static let toolbarHeight: CGFloat = 44 // I wish we didn't have to do this?

	public init(tweakStore: TweakStore) {
		self.tweakStore = tweakStore
		self.navController = UINavigationController(rootViewController: TweaksCollectionsListViewController(tweakStore: tweakStore))

		super.init(nibName: nil, bundle: nil)

		navController.toolbarHidden = true
		view.addSubview(navController.view)

		let toolbar = UIToolbar()
		var toolbarFrame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: TweaksViewController.toolbarHeight)
		toolbarFrame.origin.y -= toolbarFrame.size.height
		toolbar.frame = toolbarFrame
		toolbar.items = [
			UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionButtonTapped"),
			UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: "Dismiss", style: .Done, target: self, action: "dismissButtonTapped")
		]
		view.addSubview(toolbar)
	}

	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: Events

	@objc private func dismissButtonTapped() {
		self.delegate?.tweaksViewControllerPressedDismiss(self)
	}

	@objc private func actionButtonTapped() {
		let alertController = UIAlertController(title: "Sharing Backups Not Yet Implemented", message: "Easy, tiger.", preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}
}