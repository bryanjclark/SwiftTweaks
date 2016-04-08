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
	func tweakCollectionViewController(tweakCollectionViewController: TweakCollectionViewController, didTapFloatingTweakGroupButtonForTweakGroup tweakGroup: TweakGroup)
}

/// Displays the contents of a TweakCollection in a table - each child TweakGroup gets a section, each Tweak<T> gets a cell.
internal final class TweakCollectionViewController: UIViewController {
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
			UIBarButtonItem(title: TweaksViewController.dismissButtonTitle, style: .Done, target: self, action: #selector(self.dismissButtonTapped))
		]
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.frame = view.bounds
		tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		tableView.delegate = self
		tableView.dataSource = self
		tableView.registerClass(TweakTableCell.self, forCellReuseIdentifier: TweakCollectionViewController.TweakTableViewCellIdentifer)
		tableView.registerClass(TweakGroupSectionHeader.self, forHeaderFooterViewReuseIdentifier: TweakGroupSectionHeader.identifier)
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

	private static let sectionFooterHeight: CGFloat = 27

	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return TweakCollectionViewController.sectionFooterHeight
	}

	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return TweakGroupSectionHeader.height
	}

	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(TweakGroupSectionHeader.identifier) as! TweakGroupSectionHeader
		headerView.tweakGroup = tweakCollection.sortedTweakGroups[section]
		headerView.delegate = self
		return headerView
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

extension TweakCollectionViewController: TweakGroupSectionHeaderDelegate {
	private func tweakGroupSectionHeaderDidPressFloatingButton(sectionHeader: TweakGroupSectionHeader) {
		guard let tweakGroup = sectionHeader.tweakGroup else { return }

		delegate.tweakCollectionViewController(self, didTapFloatingTweakGroupButtonForTweakGroup: tweakGroup)
	}
}

private protocol TweakGroupSectionHeaderDelegate: class {
	func tweakGroupSectionHeaderDidPressFloatingButton(sectionHeader: TweakGroupSectionHeader)
}

/// Displays the name of a tweak group, and includes a (+) button to present the floating TweakGroup UI when tapped.
private final class TweakGroupSectionHeader: UITableViewHeaderFooterView {
	static let identifier = "TweakGroupSectionHeader"

	private let floatingButton: UIButton = {
		let button = UIButton(type: .Custom)
		let buttonImage = UIImage(swiftTweaksImage: .FloatingPlusButton).imageWithRenderingMode(.AlwaysTemplate)
		button.setImage(buttonImage.imageTintedWithColor(AppTheme.Colors.controlTinted), forState: .Normal)
		button.setImage(buttonImage.imageTintedWithColor(AppTheme.Colors.controlTintedPressed), forState: .Highlighted)
		return button
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = AppTheme.Colors.sectionHeaderTitleColor
		label.font = AppTheme.Fonts.sectionHeaderTitleFont

		return label
	}()

	private weak var delegate: TweakGroupSectionHeaderDelegate?

	var tweakGroup: TweakGroup? {
		didSet {
			titleLabel.text = tweakGroup?.title
		}
	}

	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)

		floatingButton.addTarget(self, action: #selector(self.floatingButtonTapped), forControlEvents: .TouchUpInside)

		contentView.addSubview(floatingButton)
		contentView.addSubview(titleLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	static let height: CGFloat = 38
	private static let horizontalMargin: CGFloat = 12
	private static let floatingButtonSize = CGSize(width: 46, height: TweakGroupSectionHeader.height)

	override private func layoutSubviews() {
		super.layoutSubviews()

		let floatingButtonFrame = CGRect(
			origin: CGPoint(
				x: self.contentView.bounds.maxX - TweakGroupSectionHeader.floatingButtonSize.width,
				y: 0
			),
			size: TweakGroupSectionHeader.floatingButtonSize
		)
		floatingButton.frame = floatingButtonFrame

		let titleLabelFrame = CGRect(
			origin: CGPoint(
				x: TweakGroupSectionHeader.horizontalMargin,
				y: 0
			),
			size: CGSize(
				width: self.contentView.bounds.width - floatingButtonFrame.width - TweakGroupSectionHeader.horizontalMargin,
				height: TweakGroupSectionHeader.height
			)
		)
		titleLabel.frame = titleLabelFrame
	}

	@objc private func floatingButtonTapped() {
		delegate!.tweakGroupSectionHeaderDidPressFloatingButton(self)
	}
}