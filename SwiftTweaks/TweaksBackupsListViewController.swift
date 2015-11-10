//
//  TweaksBackupsListViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/10/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal class TweaksBackupsListViewController: UIViewController {
	private let tableView: UITableView
	private let tweakStore: TweakStore

	init(tweakStore: TweakStore) {
		self.tweakStore = tweakStore
		self.tableView = UITableView(frame: CGRectZero, style: .Plain)

		super.init(nibName: nil, bundle: nil)

		toolbarItems = [
			UIBarButtonItem(title: "New", style: .Plain, target: self, action: "newButtonTapped"),
			UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: "Dismiss", style: .Done, target: self, action: "dismissButtonTapped")
		]
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		tableView.frame = view.bounds
	}


	// MARK: Events

	@objc private func newButtonTapped() {
		print("Tapped new button")
	}

	@objc private func dismissButtonTapped() {
		print("Tapped dismiss button")
	}
}


