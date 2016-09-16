//
//  TweaksBackupsListViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/10/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal protocol TweaksBackupsListViewControllerDelegate {
	func tweaksBackupsListDidPressDismiss(_ tweaksBackupsListViewController: TweaksBackupsListViewController)
}

/// Lists out the TweakBackups in a given TweakStore.
internal final class TweaksBackupsListViewController: UIViewController {
	fileprivate let tableView: UITableView
	fileprivate let tweakStore: TweakStore
	fileprivate let delegate: TweaksBackupsListViewControllerDelegate

	init(tweakStore: TweakStore, delegate: TweaksBackupsListViewControllerDelegate) {
		self.tweakStore = tweakStore
		self.delegate = delegate

		self.tableView = UITableView(frame: CGRect.zero, style: .plain)

		super.init(nibName: nil, bundle: nil)

		toolbarItems = [
			UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(self.newButtonTapped)),
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(self.dismissButtonTapped))
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

	@objc fileprivate func newButtonTapped() {
		
	}

	@objc fileprivate func dismissButtonTapped() {
		delegate.tweaksBackupsListDidPressDismiss(self)
	}
}


