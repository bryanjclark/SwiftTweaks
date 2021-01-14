//
//  TweakColorEditViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/16/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal protocol TweakColorEditViewControllerDelegate: class {
	func tweakColorEditViewControllerDidPressDismissButton(_ tweakColorEditViewController: TweakColorEditViewController)
}

/// A fullscreen color editor with hex, RGBa, and HSBa controls
internal final class TweakColorEditViewController: UIViewController {
	private let tweak: Tweak<UIColor>
	private let tweakStore: TweakStore
	private unowned var delegate: TweakColorEditViewControllerDelegate

	fileprivate var viewData: ColorRepresentation {
		didSet {
			if oldValue.type != viewData.type {
				segmentedControl.selectedSegmentIndex = viewData.type.rawValue
				tableView.reloadData()
			}

			tweakStore.setValue(.color(value: viewData.color, defaultValue: tweak.defaultValue), forTweak: AnyTweak(tweak: tweak))

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
		let tableView = UITableView(frame: CGRect.zero, style: .plain)
		tableView.allowsSelection = false
		tableView.keyboardDismissMode = .onDrag
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
		assert(anyTweak.tweakViewDataType == .uiColor, "Can only edit colors in TweakColorEditViewController")

		self.tweak = anyTweak.tweak as! Tweak<UIColor>
		self.tweakStore = tweakStore
		self.viewData = ColorRepresentation(type: .hex, color: tweakStore.currentValueForTweak(tweak))
		self.delegate = delegate

		super.init(nibName:nil, bundle: nil)

		title = tweak.tweakName
		toolbarItems = [
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: TweaksViewController.dismissButtonTitle, style: .done, target: self, action: #selector(self.dismissButtonTapped))
		]

		view.tintColor = AppTheme.Colors.controlGrayscale

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(TweakColorEditViewController.restoreDefaultColor))
		self.navigationItem.rightBarButtonItem?.tintColor = AppTheme.Colors.controlDestructive

		segmentedControl.addTarget(self, action: #selector(self.segmentedControlChanged(_:)), for: .valueChanged)
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

		headerView.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: view.bounds.width, height: 122))

		colorPreviewView.frame = CGRect(
			x: TweakColorEditViewController.headerVerticalMargin,
			y: TweakColorEditViewController.headerHorizontalMargin,
			width: view.bounds.width - 2 * TweakColorEditViewController.headerHorizontalMargin,
			height: TweakColorEditViewController.colorPreviewHeight
		)
        let frames = colorPreviewView.bounds.divided(atDistance: colorPreviewView.bounds.width/2, from: .minXEdge)
        let solidFrame = frames.slice
        
		colorPreviewSolidView.frame = solidFrame.integral
		colorPreviewAlphaView.frame = colorPreviewView.bounds
		colorPreviewView.addSubview(colorPreviewAlphaView)
		colorPreviewView.addSubview(colorPreviewSolidView)
		headerView.addSubview(colorPreviewView)

		segmentedControl.sizeToFit()
		segmentedControl.frame = CGRect(
			origin: CGPoint(x: colorPreviewView.frame.minX, y: colorPreviewView.frame.maxY + TweakColorEditViewController.headerVerticalMargin),
			size: CGSize(width: headerView.bounds.width - 2 * TweakColorEditViewController.headerHorizontalMargin, height: segmentedControl.bounds.height)
		)
		headerView.addSubview(segmentedControl)
		tableView.tableHeaderView = headerView

		tableView.frame = view.bounds
		tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		tableView.dataSource = self
		tableView.register(TweakColorCell.self, forCellReuseIdentifier: TweakColorEditViewController.SliderCellIdentifier)
		view.addSubview(tableView)

		updateColorPreview()
		segmentedControl.selectedSegmentIndex = viewData.type.rawValue
	}

	fileprivate static let SliderCellIdentifier = "SliderCellIdentifier"

	@objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
		assert(sender == segmentedControl, "Unknown sender in segmentedControlChanged:")
		colorRepresentationType = ColorRepresentationType(rawValue: sender.selectedSegmentIndex)!
	}

	@objc private func dismissButtonTapped() {
		delegate.tweakColorEditViewControllerDidPressDismissButton(self)
	}

	private func updateColorPreview() {
		colorPreviewView.backgroundColor = UIColor.white
		colorPreviewSolidView.backgroundColor = viewData.color.withAlphaComponent(1.0)
		colorPreviewAlphaView.backgroundColor = viewData.color
	}

	@objc private func restoreDefaultColor() {
		let confirmationAlert = UIAlertController(title: "Reset This Color to Default?", message: "Your other tweaks will be left alone.", preferredStyle: .actionSheet)
		confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		confirmationAlert.addAction(UIAlertAction(title: "Reset This Color", style: .destructive, handler: { _ in
			self.viewData = ColorRepresentation(type: .hex, color: self.tweak.defaultValue)
		}))
		present(confirmationAlert, animated: true, completion: nil)
	}
}

extension TweakColorEditViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return TweakColorCell.cellHeight
	}
}

extension TweakColorEditViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewData.numberOfComponents 
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: TweakColorEditViewController.SliderCellIdentifier, for: indexPath) as! TweakColorCell
		cell.viewData = viewData[(indexPath as NSIndexPath).row]
		cell.delegate = self
		return cell
	}
}

extension TweakColorEditViewController: TweakColorCellDelegate {
	func tweakColorCellDidChangeValue(_ cell: TweakColorCell) {
		let changedValue = cell.viewData!

		switch viewData {
		case let .hex(hex: oldHex, alpha: oldAlpha):
			switch changedValue {
			case let .hexComponent(newHex):
				viewData = .hex(hex: newHex, alpha: oldAlpha)
			case let .numericalComponent(newNumber):
				viewData = .hex(hex: oldHex, alpha: newNumber)
			}
		case let .rgBa(r: oldR, g: oldG, b: oldB, a: oldA):
			// NOTE : See discussion on https://github.com/Khan/SwiftTweaks/issues/152 for why this guard-statement is necessary
			guard
				let numericType = changedValue.numericType,
				let numericValue = changedValue.numericValue
			else {
				return
			}

			switch numericType {
			case .red:
				viewData = .rgBa(r: numericValue, g: oldG, b: oldB, a: oldA)
			case .green:
				viewData = .rgBa(r: oldR, g: numericValue, b: oldB, a: oldA)
			case .blue:
				viewData = .rgBa(r: oldR, g: oldG, b: numericValue, a: oldA)
			case .alpha:
				viewData = .rgBa(r: oldR, g: oldG, b: oldB, a: numericValue)
			case .hue, .saturation, .brightness:
				break
			}
		case let .hsBa(h: oldH, s: oldS, b: oldB, a: oldA):
			// NOTE : See discussion on https://github.com/Khan/SwiftTweaks/issues/152 for why this guard-statement is necessary
			guard
				let numericType = changedValue.numericType,
				let numericValue = changedValue.numericValue
			else {
				return
			}

			switch numericType {
			case .hue:
				viewData = .hsBa(h: numericValue, s: oldS, b: oldB, a: oldA)
			case .saturation:
				viewData = .hsBa(h: oldH, s: numericValue, b: oldB, a: oldA)
			case .brightness:
				viewData = .hsBa(h: oldH, s: oldS, b: numericValue, a: oldA)
			case .alpha:
				viewData = .hsBa(h: oldH, s: oldS, b: oldB, a: numericValue)
			case .red, .green, .blue:
				break
			}
		}
	}
}
