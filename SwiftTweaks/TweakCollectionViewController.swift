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
	private let tableView = UITableView(frame: CGRectZero, style: .Grouped)

	private let tweakCollection: TweakCollection
	private let tweakStore: TweakStore

	private let delegate: TweakCollectionViewControllerDelegate

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
		tableView.registerClass(SwitchCell.self, forCellReuseIdentifier: TweakCollectionViewController.SwitchCellIdentifier)
		tableView.registerClass(StepperCell.self, forCellReuseIdentifier: TweakCollectionViewController.StepperCellIdentifier)
		tableView.registerClass(ColorCell.self, forCellReuseIdentifier: TweakCollectionViewController.ColorCellIdentifier)
		view.addSubview(tableView)
	}


	// MARK: Events

	@objc private func dismissButtonTapped() {
		delegate.tweakCollectionViewControllerDidPressDismissButton(self)
	}


	// MARK: Table Cells

	private static let TweakTableViewCellIdentifer = "TweakTableViewCellIdentifer"
	private static let SwitchCellIdentifier = "SwitchCellIdentifier"
	private static let StepperCellIdentifier = "StepperCellIdentifier"
	private static let ColorCellIdentifier = "ColorCellIdentifier"

	internal class StepperCell: UITableViewCell {
		internal let stepperControl = UIStepper()

		override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
			super.init(style: .Default, reuseIdentifier: reuseIdentifier)

			accessoryView = stepperControl
		}

		required init?(coder aDecoder: NSCoder) {
		    fatalError("init(coder:) has not been implemented")
		}
	}

	internal class SwitchCell: UITableViewCell {
		let switchControl = UISwitch()

		override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
			super.init(style: .Default, reuseIdentifier: reuseIdentifier)

			accessoryView = switchControl
		}

		required init?(coder aDecoder: NSCoder) {
		    fatalError("init(coder:) has not been implemented")
		}
	}

	internal class ColorCell: UITableViewCell {
		private static let chitSize = CGSize(width: 29, height: 29)
		let colorChit: UIView = {
			let view = UIView(frame: CGRect(origin: CGPointZero, size: chitSize))
			view.layer.cornerRadius = 4
			view.clipsToBounds = true
			return view
		}()

		override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
			super.init(style: .Default, reuseIdentifier: reuseIdentifier)

			accessoryView = colorChit
		}

		required init?(coder aDecoder: NSCoder) {
		    fatalError("init(coder:) has not been implemented")
		}
	}
}

extension TweakCollectionViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		print("yay! You selected a thing")
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
		let tweak = tweakCollection.sortedTweakGroups[indexPath.section].sortedTweaks[indexPath.row]

		let cell: UITableViewCell
		switch tweak.tweakViewData {
		case let .Stepper(value: value):
			let stepperCell  = tableView.dequeueReusableCellWithIdentifier(TweakCollectionViewController.StepperCellIdentifier, forIndexPath: indexPath) as! StepperCell
			stepperCell.stepperControl.value = value
			cell = stepperCell as UITableViewCell
		case let .Color(value: value):
			let colorCell = tableView.dequeueReusableCellWithIdentifier(TweakCollectionViewController.ColorCellIdentifier, forIndexPath: indexPath) as! ColorCell
			// TODO (bryan) set color parameters
			colorCell.colorChit.backgroundColor = UIColor.grayColor()
			cell = colorCell as UITableViewCell
		case let .Switch(value: value):
			let boolCell = tableView.dequeueReusableCellWithIdentifier(TweakCollectionViewController.SwitchCellIdentifier, forIndexPath: indexPath) as! SwitchCell
			boolCell.switchControl.on = value
			cell = boolCell as UITableViewCell
		}
		cell.textLabel?.text = tweak.tweakName
		return cell
	}

	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return tweakCollection.sortedTweakGroups[section].title
	}
}
