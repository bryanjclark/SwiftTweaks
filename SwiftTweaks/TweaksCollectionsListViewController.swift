//
//  TweaksCollectionsListViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/9/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal protocol TweaksCollectionsListViewControllerDelegate {
	func tweaksCollectionsListViewControllerDidTapDismissButton(_ tweaksCollectionsListViewController: TweaksCollectionsListViewController)
	func tweaksCollectionsListViewController(_ tweaksCollectionsListViewController: TweaksCollectionsListViewController, didSelectTweakCollection: TweakCollection)
	func tweaksCollectionsListViewControllerDidTapShareButton(_ tweaksCollectionsListViewController: TweaksCollectionsListViewController, shareButton: UIBarButtonItem)
}

/// Displays a list of TweakCollections in a table.
internal final class TweaksCollectionsListViewController: UIViewController {
	private let tableView: UITableView

	fileprivate let tweakStore: TweakStore
	fileprivate let delegate: TweaksCollectionsListViewControllerDelegate


	// MARK: Init

	internal init(tweakStore: TweakStore, delegate: TweaksCollectionsListViewControllerDelegate) {
		self.tweakStore = tweakStore
		self.delegate = delegate

		self.tableView = UITableView(frame: CGRect.zero, style: .plain)

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: View Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.frame = view.bounds
		tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		tableView.register(TweakCollectionCell.self, forCellReuseIdentifier: TweaksCollectionsListViewController.TweakCollectionCellIdentifier)
		tableView.delegate = self
		tableView.dataSource = self
		view.addSubview(tableView)

		let resetButton = UIBarButtonItem(title: "Reset All", style: .plain, target: self, action: #selector(self.resetStore))
		resetButton.tintColor = AppTheme.Colors.controlDestructive
		navigationItem.rightBarButtonItem = resetButton

		let exportButton = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(self.actionButtonTapped))
		exportButton.tintColor = AppTheme.Colors.controlTinted
		navigationItem.leftBarButtonItem = exportButton

		toolbarItems = [
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(self.dismissButtonTapped))
		]
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if let selectedIndexPath = tableView.indexPathForSelectedRow {
			tableView.deselectRow(at: selectedIndexPath, animated: true)
		}
	}

	// MARK: Events

	@objc private func resetStore(_ sender: UIBarButtonItem) {
		let confirmationAlert = UIAlertController(title: nil, message: "Reset all tweaks to their default values?", preferredStyle: .actionSheet)
		confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		confirmationAlert.addAction(UIAlertAction(title: "Reset All Tweaks", style: .destructive, handler: { _ in self.tweakStore.reset() }))
		confirmationAlert.popoverPresentationController?.barButtonItem = sender
		present(confirmationAlert, animated: true, completion: nil)
	}

	@objc private func dismissButtonTapped() {
		delegate.tweaksCollectionsListViewControllerDidTapDismissButton(self)
	}

	@objc private func actionButtonTapped(_ sender: UIBarButtonItem) {
		delegate.tweaksCollectionsListViewControllerDidTapShareButton(self, shareButton: sender)
	}

	fileprivate static let TweakCollectionCellIdentifier = "TweakCollectionCellIdentifier"
	private class TweakCollectionCell: UITableViewCell {
		override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
			super.init(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
			accessoryType = .disclosureIndicator
		}

		required init?(coder aDecoder: NSCoder) {
		    fatalError("init(coder:) has not been implemented")
		}
	}
}

extension TweaksCollectionsListViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tweakStore.sortedTweakCollections.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: TweaksCollectionsListViewController.TweakCollectionCellIdentifier, for: indexPath)
		let tweakCollection = tweakStore.sortedTweakCollections[(indexPath as NSIndexPath).row]
		cell.textLabel!.text = tweakCollection.title
		cell.detailTextLabel!.text = "\(tweakCollection.numberOfTweaks)"
		return cell
	}
}

extension TweaksCollectionsListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		delegate.tweaksCollectionsListViewController(self, didSelectTweakCollection: tweakStore.sortedTweakCollections[(indexPath as NSIndexPath).row])
	}
}
