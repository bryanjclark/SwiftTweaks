//
//  TweakColorEditViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/16/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal protocol TweakColorEditViewControllerDelegate {
	func tweakColorEditViewControllerDidPressDismissButton(tweakColorEditViewController: TweakColorEditViewController)
}

/// A fullscreen color editor with hex, RGBa, and HSBa controls
internal final class TweakColorEditViewController: UIViewController {
	private let tweak: Tweak<UIColor>
	private let tweakStore: TweakStore
	private let delegate: TweakColorEditViewControllerDelegate

	private var viewData: ColorRepresentation {
		didSet {
			if oldValue.type != viewData.type {
				segmentedControl.selectedSegmentIndex = viewData.type.rawValue
				tableView.reloadData()
			}

			tweakStore.setValue(.Color(value: viewData.color, defaultValue: tweak.defaultValue), forTweak: AnyTweak(tweak: tweak))

			updateColorPreview()
		}
	}

	private var colorRepresentationType: ColorRepresentationType {
		set {
			viewData = ColorRepresentation(type: newValue, color: viewData.color)
		}
		get {
			return viewData.type
		}
	}

	private let tableView: UITableView = {
		let tableView = UITableView(frame: CGRectZero, style: .Plain)
		tableView.allowsSelection = false
		tableView.keyboardDismissMode = .OnDrag
		return tableView
	}()

	private let headerView: UIView = UIView()
	private let colorPreviewView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 4
		view.clipsToBounds = true
		return view
	}()
	private let colorPreviewSolidView = UIView()
	private let colorPreviewAlphaView = UIView()

	private let segmentedControl: UISegmentedControl = {
		let control = UISegmentedControl(items: ColorRepresentationType.titles)
		return control
	}()

	// MARK: Init

	init(anyTweak: AnyTweak, tweakStore: TweakStore, delegate: TweakColorEditViewControllerDelegate) {
		assert(anyTweak.tweakViewDataType == .UIColor, "Can only edit colors in TweakColorEditViewController")

		self.tweak = anyTweak.tweak as! Tweak<UIColor>
		self.tweakStore = tweakStore
		self.viewData = ColorRepresentation(type: .Hex, color: tweakStore.currentValueForTweak(tweak))
		self.delegate = delegate

		super.init(nibName:nil, bundle: nil)

		title = tweak.tweakName
		toolbarItems = [
			UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: TweaksViewController.dismissButtonTitle, style: .Done, target: self, action: #selector(self.dismissButtonTapped))
		]

		view.tintColor = AppTheme.Colors.controlGrayscale

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .Plain, target: self, action: #selector(TweakColorEditViewController.restoreDefaultColor))
		self.navigationItem.rightBarButtonItem?.tintColor = AppTheme.Colors.controlDestructive

		segmentedControl.addTarget(self, action: #selector(self.segmentedControlChanged(_:)), forControlEvents: .ValueChanged)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private static let headerHeight: CGFloat = 122
	private static let colorPreviewHeight: CGFloat = 64
	private static let headerHorizontalMargin: CGFloat = 10
	private static let headerVerticalMargin: CGFloat = 10

	override func viewDidLoad() {
		super.viewDidLoad()

		headerView.bounds = CGRect(origin: CGPointZero, size: CGSize(width: view.bounds.width, height: 122))

		colorPreviewView.frame = CGRect(
			x: TweakColorEditViewController.headerVerticalMargin,
			y: TweakColorEditViewController.headerHorizontalMargin,
			width: view.bounds.width - 2 * TweakColorEditViewController.headerHorizontalMargin,
			height: TweakColorEditViewController.colorPreviewHeight
		)
		var solidFrame = CGRect()
		var remainder = CGRect()
		CGRectDivide(colorPreviewView.bounds, &solidFrame, &remainder, colorPreviewView.bounds.width/2, CGRectEdge.MinXEdge)
		colorPreviewSolidView.frame = CGRectIntegral(solidFrame)
		colorPreviewAlphaView.frame = colorPreviewView.bounds
		colorPreviewView.addSubview(colorPreviewAlphaView)
		colorPreviewView.addSubview(colorPreviewSolidView)
		headerView.addSubview(colorPreviewView)

		segmentedControl.sizeToFit()
		segmentedControl.frame = CGRect(
			origin: CGPoint(x: CGRectGetMinX(colorPreviewView.frame), y: CGRectGetMaxY(colorPreviewView.frame) + TweakColorEditViewController.headerVerticalMargin),
			size: CGSize(width: headerView.bounds.width - 2 * TweakColorEditViewController.headerHorizontalMargin, height: segmentedControl.bounds.height)
		)
		headerView.addSubview(segmentedControl)
		tableView.tableHeaderView = headerView

		tableView.frame = view.bounds
		tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		tableView.dataSource = self
		tableView.registerClass(TweakColorCell.self, forCellReuseIdentifier: TweakColorEditViewController.SliderCellIdentifier)
		view.addSubview(tableView)

		updateColorPreview()
		segmentedControl.selectedSegmentIndex = viewData.type.rawValue
	}

	private static let SliderCellIdentifier = "SliderCellIdentifier"

	@objc private func segmentedControlChanged(sender: UISegmentedControl) {
		assert(sender == segmentedControl, "Unknown sender in segmentedControlChanged:")
		colorRepresentationType = ColorRepresentationType(rawValue: sender.selectedSegmentIndex)!
	}

	@objc private func dismissButtonTapped() {
		delegate.tweakColorEditViewControllerDidPressDismissButton(self)
	}

	private func updateColorPreview() {
		colorPreviewView.backgroundColor = .clearColor()
		colorPreviewSolidView.backgroundColor = viewData.color.colorWithAlphaComponent(1.0)
		colorPreviewAlphaView.backgroundColor = viewData.color
	}

	@objc private func restoreDefaultColor() {
		let confirmationAlert = UIAlertController(title: "Reset This Color to Default?", message: "Your other tweaks will be left alone.", preferredStyle: .ActionSheet)
		confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		confirmationAlert.addAction(UIAlertAction(title: "Reset This Color", style: .Destructive, handler: { _ in
			self.viewData = ColorRepresentation(type: .Hex, color: self.tweak.defaultValue)
		}))
		presentViewController(confirmationAlert, animated: true, completion: nil)
	}
}

extension TweakColorEditViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return TweakColorCell.cellHeight
	}
}

extension TweakColorEditViewController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewData.numberOfComponents ?? 0
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(TweakColorEditViewController.SliderCellIdentifier, forIndexPath: indexPath) as! TweakColorCell
		cell.viewData = viewData[indexPath.row]
		cell.delegate = self
		return cell
	}
}

extension TweakColorEditViewController: TweakColorCellDelegate {
	func tweakColorCellDidChangeValue(cell: TweakColorCell) {
		let changedValue = cell.viewData!

		switch viewData {
		case let .Hex(hex: oldHex, alpha: oldAlpha):
			switch changedValue {
			case let .HexComponent(newHex):
				viewData = .Hex(hex: newHex, alpha: oldAlpha)
			case let .NumericalComponent(newNumber):
				viewData = .Hex(hex: oldHex, alpha: newNumber)
			}
		case let .RGBa(r: oldR, g: oldG, b: oldB, a: oldA):
			switch changedValue.numericType! {
			case .Red:
				viewData = .RGBa(r: changedValue.numericValue!, g: oldG, b: oldB, a: oldA)
			case .Green:
				viewData = .RGBa(r: oldR, g: changedValue.numericValue!, b: oldB, a: oldA)
			case .Blue:
				viewData = .RGBa(r: oldR, g: oldG, b: changedValue.numericValue!, a: oldA)
			case .Alpha:
				viewData = .RGBa(r: oldR, g: oldG, b: oldB, a: changedValue.numericValue!)
			case .Hue, .Saturation, .Brightness:
				break
			}
		case let .HSBa(h: oldH, s: oldS, b: oldB, a: oldA):
			switch changedValue.numericType! {
			case .Hue:
				viewData = .HSBa(h: changedValue.numericValue!, s: oldS, b: oldB, a: oldA)
			case .Saturation:
				viewData = .HSBa(h: oldH, s: changedValue.numericValue!, b: oldB, a: oldA)
			case .Brightness:
				viewData = .HSBa(h: oldH, s: oldS, b: changedValue.numericValue!, a: oldA)
			case .Alpha:
				viewData = .HSBa(h: oldH, s: oldS, b: oldB, a: changedValue.numericValue!)
			case .Red, .Green, .Blue:
				break
			}
		}
	}
}