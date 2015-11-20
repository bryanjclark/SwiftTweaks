//
//  TweakCollectionViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/10/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal protocol TweakCollectionViewControllerDelegate {
	func tweakCollectionViewControllerDidPressDismissButton(tweakCollectionViewController: TweakCollectionViewController)
}

internal class TweakCollectionViewController: UIViewController {
	private let tweakCollection: TweakCollection
	private let tweakStore: TweakStore

	private let delegate: TweakCollectionViewControllerDelegate

	private let tableView: UITableView = {
		let tableView = UITableView(frame: CGRectZero, style: .Grouped)
		tableView.keyboardDismissMode = .OnDrag
		return tableView
	}()

	init(tweakCollection: TweakCollection, tweakStore: TweakStore, delegate: TweakCollectionViewControllerDelegate) {
		self.tweakCollection = tweakCollection
		self.tweakStore = tweakStore
		self.delegate = delegate

		super.init(nibName: nil, bundle: nil)

		title = tweakCollection.title

		toolbarItems = [
			UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: TweaksViewController.dismissButtonTitle, style: .Done, target: self, action: "dismissButtonTapped")
		]
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.frame = view.bounds
		tableView.delegate = self
		tableView.dataSource = self
		tableView.registerClass(TweakTableCell.self, forCellReuseIdentifier: TweakCollectionViewController.TweakTableViewCellIdentifer)
		view.addSubview(tableView)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		// Reload data (in case colors were changed on a divedown)
		tableView.reloadData()
	}


	// MARK: Events

	@objc private func dismissButtonTapped() {
		delegate.tweakCollectionViewControllerDidPressDismissButton(self)
	}


	// MARK: Table Cells

	private static let TweakTableViewCellIdentifer = "TweakTableViewCellIdentifer"

}

extension TweakCollectionViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let tweak = tweakAtIndexPath(indexPath)
		switch tweak.tweakViewDataType {
		case .UIColor:
			let colorEditVC = TweakColorEditViewController(anyTweak: tweak, tweakStore: tweakStore, delegate: self)
			navigationController?.pushViewController(colorEditVC, animated: true)
		case .Boolean, .Integer, .CGFloat, .Double:
			break
		}
	}
}

extension TweakCollectionViewController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return tweakCollection.tweakGroups.count
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tweakCollection.sortedTweakGroups[section].tweaks.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let tweak = tweakAtIndexPath(indexPath)

		let cell = tableView.dequeueReusableCellWithIdentifier(TweakCollectionViewController.TweakTableViewCellIdentifer, forIndexPath: indexPath) as! TweakTableCell
		cell.textLabel?.text = tweak.tweakName
		cell.viewData = tweakStore.currentViewDataForTweak(tweak)
		cell.delegate = self
		return cell
	}

	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return tweakCollection.sortedTweakGroups[section].title
	}

	private func tweakAtIndexPath(indexPath: NSIndexPath) -> AnyTweak {
		return tweakCollection.sortedTweakGroups[indexPath.section].sortedTweaks[indexPath.row]
	}
}

extension TweakCollectionViewController: TweakTableCellDelegate {
	func tweakCellDidChangeCurrentValue(tweakCell: TweakTableCell) {
		if let
			indexPath = tableView.indexPathForCell(tweakCell),
			viewData = tweakCell.viewData
		{
			let tweak = tweakAtIndexPath(indexPath)
			tweakStore.setValue(viewData, forTweak: tweak)
		}
	}
}

extension TweakCollectionViewController: TweakColorEditViewControllerDelegate {
	func tweakColorEditViewControllerDidPressDismissButton(tweakColorEditViewController: TweakColorEditViewController) {
		self.delegate.tweakCollectionViewControllerDidPressDismissButton(self)
	}
}