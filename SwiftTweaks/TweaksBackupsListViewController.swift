//
//  TweaksBackupsListViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/10/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal protocol TweaksBackupsListViewControllerDelegate {
	func tweaksBackupsListDidPressDismiss(tweaksBackupsListViewController: TweaksBackupsListViewController)
}

/// Lists out the TweakBackups in a given TweakStore.
internal final class TweaksBackupsListViewController: UIViewController {
	private let tableView: UITableView
	private let tweakStore: TweakStore
	private let delegate: TweaksBackupsListViewControllerDelegate

	init(tweakStore: TweakStore, delegate: TweaksBackupsListViewControllerDelegate) {
		self.tweakStore = tweakStore
		self.delegate = delegate

		self.tableView = UITableView(frame: CGRectZero, style: .Plain)

		super.init(nibName: nil, bundle: nil)

		toolbarItems = [
			UIBarButtonItem(title: "New", style: .Plain, target: self, action: #selector(self.newButtonTapped)),
			UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: "Dismiss", style: .Done, target: self, action: #selector(self.dismissButtonTapped))
		]
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.frame = view.bounds
		view.addSubview(tableView)
	}


	// MARK: Events

	@objc private func newButtonTapped() {
		
	}

	@objc private func dismissButtonTapped() {
		delegate.tweaksBackupsListDidPressDismiss(self)
	}
}


